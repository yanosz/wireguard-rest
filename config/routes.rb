Rails.application.routes.draw do
  resources :key_registrations, only: [:index,:create] do
    delete :destroy, on: :collection
  end
  root 'key_registrations#index'
end
