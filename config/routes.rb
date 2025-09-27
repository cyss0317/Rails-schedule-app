# frozen_string_literal: true

def set_up_flipper
  flipper_app = Flipper::UI.app(Flipper.instance) do |builder|
    builder.use Rack::Auth::Basic do |username, password|
      username == ENV['FLIPPER_USERNAME'] && password == ENV['FLIPPER_PASSWORD']
    end
  end
  mount flipper_app, at: '/flipper'
end

Rails.application.routes.draw do
  set_up_flipper

  root to: 'home#index'
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions',
    passwords: 'users/passwords',
    confirmation: 'users/confirmations'
  }
  resources :companies, only: %i[new create update edit index destroy] do
    resources :locations, only: %i[new create update edit index destroy], shallow: true
  end

  resources :locations, only: [] do
    resources :day_offs, shallow: true
    resources :meetings, shallow: true do
      collection do
        get 'weekly', to: 'meetings#weekly'
        get 'monthly', to: 'meetings#monthly'
        post 'seed', to: 'meetings#seed'
        post 'copy_previous_week_schedule'
        delete 'clear_selected_week'
      end
    end
    resources :location_users, shallow: true, only: %i[index update]
  end
  # devise_for :registrations
  # namespace :users do
  #   resources :registrations, only: %i[new create]
  # end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
