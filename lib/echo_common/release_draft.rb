# coding: utf-8
module EchoCommon
  class ReleaseDraft < EchoCommon::Entity
    attributes :external_foreign_key
    attributes :title, :display_title, :main_artist

    attributes :record_label, :c_line, :p_line
    attributes :release_date

    attributes :barcode, :catalog_number

    # Ex. Sony, UMG etc.
    attributes :source
  end
end
