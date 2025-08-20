# Reporting

A Rails engine for asynchronous report generation with background job processing, file storage, and API endpoints for managing report requests.

## Features

- 🚀 **Asynchronous Processing**: Generate reports in background jobs using Sidekiq
- 📁 **File Storage**: Automatic file attachment using Active Storage
- 🔒 **Secure Downloads**: Token-based download URLs with configurable expiration
- 🎛️ **Configurable**: Customizable authorization, queue names, and user context
- 📊 **Multiple Report Types**: Registry pattern for supporting different report services
- 📈 **Status Tracking**: Real-time status updates (queued, processing, done, failed)
- 🛡️ **Error Handling**: Comprehensive error handling and logging
- 🔑 **Authentication**: Configurable user authentication and authorization

## Requirements

- Ruby >= 3.0
- Rails >= 7.0.4, < 7.2
- Sidekiq >= 6 (for background job processing)
- Active Storage configured for file attachments

## Installation

Add this line to your application's Gemfile:

```ruby
gem "reporting"
```

And then execute:
```bash
$ bundle install
```

Run the install generator to create the initializer:
```bash
$ rails generate reporting:install
```

Run the migration to create the required database table:
```bash
$ rails db:migrate
```

Mount the engine routes in your `config/routes.rb`:
```ruby
mount Reporting::Engine => "/api"
```

## Configuration

After running the install generator, configure the gem in `config/initializers/reporting.rb`:

```ruby
Reporting.configure do
  # Background job queue name (default: :reports)
  self.queue_name = :reports
  
  # Download URL expiration time (default: 15.minutes)
  self.expires_in = 20.minutes
  
  # Define how to get the current user from the controller
  self.current_user_proc = ->(controller) { controller.try(:current_user) }
  
  # Define authorization logic for report access (default: always allow)
  self.authorize_proc = ->(controller, report) { 
    # Example: only allow users to access their own reports
    report.requester_id == controller.current_user&.id 
  }

  # Register your report services
  register :sales, "Reports::SalesReportService"
  register :inventory, "Reports::InventoryReportService"
  register :user_analytics, "Reports::UserAnalyticsService"
end
```

## Usage

### 1. Create a Report Service

Create a service class that generates your report:

```ruby
# app/services/reports/sales_report_service.rb
module Reports
  class SalesReportService
    def initialize(params, context: {})
      @params = params
      @context = context
    end

    def call
      # Generate your report data
      csv_data = generate_sales_csv
      
      # Return [IO, filename, content_type]
      [
        StringIO.new(csv_data),
        "sales_report_#{Date.current}.csv",
        "text/csv"
      ]
    end

    private

    def generate_sales_csv
      # Your report generation logic here
      CSV.generate do |csv|
        csv << ["Date", "Product", "Sales"]
        # Add your data rows...
      end
    end
  end
end
```

### 2. Register Your Report Service

In your `config/initializers/reporting.rb`:

```ruby
Reporting.configure do
  # ... other configuration ...
  
  register :sales, "Reports::SalesReportService"
end
```

### 3. Generate Reports via API

**Create a Report Request:**

```bash
POST /api/reporting/reports
Content-Type: application/json

{
  "kind": "sales",
  "params": {
    "start_date": "2024-01-01",
    "end_date": "2024-01-31",
    "format": "csv"
  }
}
```

**Response:**
```json
{
  "token": "abc123xyz789",
  "status": "queued"
}
```

**Check Report Status:**

```bash
GET /api/reporting/reports/abc123xyz789
```

**Response (Processing):**
```json
{
  "status": "processing"
}
```

**Response (Completed):**
```json
{
  "status": "done",
  "download_url": "https://your-app.com/rails/active_storage/disk/..."
}
```

**Response (Failed):**
```json
{
  "status": "failed",
  "error": "Error message describing what went wrong"
}
```

### 4. Using in Your Rails Application

You can also generate reports programmatically:

```ruby
# Create a report request
report_request = Reporting::ReportRequest.create!(
  kind: "sales",
  params: { start_date: "2024-01-01", end_date: "2024-01-31" },
  requester: current_user
)

# Queue the background job
Reporting::GenerateReportJob.perform_later(report_request.id)

# Check status later
puts report_request.reload.status # => "queued", "processing", "done", or "failed"

# Get download URL when done
if report_request.status_done?
  url = report_request.file.blob.service_url(expires_in: 20.minutes)
  # Use the URL for downloads
end
```

## API Reference

### POST /api/reporting/reports

Creates a new report generation request.

**Parameters:**
- `kind` (required): The type of report to generate (must be registered)
- `params` (optional): Hash of parameters to pass to the report service

**Response:** `202 Accepted`
```json
{
  "token": "unique-report-token",
  "status": "queued"
}
```

### GET /api/reporting/reports/:token

Retrieves the status and download URL for a report.

**Response:** `200 OK` (when done)
```json
{
  "status": "done",
  "download_url": "https://your-app.com/download-url"
}
```

**Response:** `202 Accepted` (when processing)
```json
{
  "status": "processing"
}
```

**Response:** `422 Unprocessable Entity` (when failed)
```json
{
  "status": "failed",
  "error": "Error message"
}
```

## Database Schema

The gem creates a `reporting_report_requests` table with the following structure:

```ruby
create_table :reporting_report_requests, id: :uuid do |t|
  t.string :token, null: false, index: { unique: true }
  t.integer :status, null: false, default: 0
  t.json :params, null: false, default: {}
  t.string :kind, null: false
  t.references :requester, polymorphic: true, type: :uuid, null: false
  t.string :error_message
  t.datetime :started_at
  t.datetime :finished_at
  t.timestamps
end
```

## Error Handling

The gem provides comprehensive error handling:

- **Invalid report kinds**: Returns validation error if report type is not registered
- **Service failures**: Captures exceptions and marks reports as failed with error messages
- **Authorization failures**: Returns 403 Forbidden for unauthorized access
- **Missing reports**: Returns 404 Not Found for invalid tokens

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Write tests for your changes
4. Make your changes and ensure tests pass
5. Commit your changes (`git commit -am 'Add some feature'`)
6. Push to the branch (`git push origin my-new-feature`)
7. Create a new Pull Request

### Development Setup

```bash
git clone https://github.com/nemuba/gem-reporting.git
cd gem-reporting
bundle install
cd spec/dummy && rails db:migrate && cd ../..
bundle exec rspec
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
