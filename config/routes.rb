Rails.application.routes.draw do
  resources :ibm_infos

  root to: 'ibm_infos#new'
end
