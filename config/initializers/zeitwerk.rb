Rails.autoloaders.each do |autoloader|
  autoloader.collapse(Rails.root.join("advertisements/lib/advertisements/events"))
  autoloader.collapse(Rails.root.join("advertisements/lib/advertisements/commands"))
end