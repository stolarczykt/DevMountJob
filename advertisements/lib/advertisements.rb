module Advertisements

  class Configuration
  end

  class OnPublishAdvertisement
    def call(command)
      repository = AdvertisementRepository::new
      repository.with_advertisement(command.advertisement_id) do |advertisement|
        advertisement.publish(command.author_id)
      end
    end
  end

  class OnResumeAdvertisement
    def call(command)
      repository = AdvertisementRepository::new
      repository.with_advertisement(command.advertisement_id) do |advertisement|
        advertisement.resume(command.requester_id)
      end
    end
  end

  class OnExpireAdvertisement
    def call(command)
      repository = AdvertisementRepository::new
      repository.with_advertisement(command.advertisement_id) do |advertisement|
        advertisement.expire
      end
    end
  end

  class OnChangeContent
    def call(command)
      repository = AdvertisementRepository::new
      repository.with_advertisement(command.advertisement_id) do |advertisement|
        advertisement.change_content(command.content, command.author_id)
      end
    end
  end

  class OnPutAdvertisementOnHold
    def call(command)
      repository = AdvertisementRepository::new
      repository.with_advertisement(command.advertisement_id) do |advertisement|
        advertisement.put_on_hold(command.requester_id)
      end
    end
  end

  class OnSuspendAdvertisement
    def call(command)
      repository = AdvertisementRepository::new
      repository.with_advertisement(command.advertisement_id) do |advertisement|
        advertisement.suspend(command.reason)
      end
    end
  end

  class OnUnblockAdvertisement
    def call(command)
      repository = AdvertisementRepository::new
      repository.with_advertisement(command.advertisement_id) do |advertisement|
        advertisement.unblock
      end
    end
  end
end
