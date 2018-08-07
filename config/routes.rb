Rails.application.routes.draw do
  root to: 'main#index'
  get '/history', to: 'main#history'
  get '/admin/login', to: 'main#login'
  post '/admin/login', to: 'main#authenticate'
  get '/admin', to: 'main#admin'
  get '/admin/logout', to: 'main#logout'
  patch '/admin/notices/:id/deactivate', controller: :main, action: :notice_deactivate
  delete '/admin/notices/:id/delete', controller: :main, action: :notice_delete
  post '/admin/notices/create', controller: :main, action: :notice_create, as: 'notices'
  get '/update', controller: :main, action: :run_update_job
  get '/results/latest', controller: :main, action: :view_results
  get '/results/:id', controller: :main, action: :view_results
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
