Rails.autoloaders.each do |autoloader|
  autoloader.collapse(Rails.root.join("advertisements/lib/advertisements/events"))
  autoloader.collapse(Rails.root.join("advertisements/lib/advertisements/commands"))
  autoloader.collapse(Rails.root.join("offering/lib/offering/events"))
  autoloader.collapse(Rails.root.join("offering/lib/offering/commands"))
  autoloader.collapse(Rails.root.join("payments/lib/payments/events"))
  autoloader.collapse(Rails.root.join("payments/lib/payments/commands"))
end