class EmissionsImporterJob < ApplicationJob
  queue_as :default
  discard_on EmissionImporter::InvalidFileException

  def perform(*args)
    EmissionImporter.new.import_from_csv(args[0])
  end
end
