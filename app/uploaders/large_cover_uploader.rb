class LargeCoverUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  version :large_version do
    process resize_to_fit: [665, 375]
  end
end
