Reporting::Engine.routes.draw do
  scope :reporting do
    resources :reports, only: [:create], controller: "reporting/reports"
    get "reports/:token", to: "reporting/reports#show"
  end
end
