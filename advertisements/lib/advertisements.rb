module Advertisements

  class OnChangeContent
    def call(command)
      repository = AdvertisementRepository::new
      repository.with_advertisement(command.advertisement_id) do |advertisement|
        advertisement.change_content(command.content)
      end
    end
  end
end
