Rails.application.routes.draw do
	root 'currency#index'
	get 'currency/live'
	get 'currency/historical'
	get 'currency/best_rate'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
