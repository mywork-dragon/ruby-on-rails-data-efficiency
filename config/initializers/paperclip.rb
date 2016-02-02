text_plain = MIME::Types["text/plain"].first
text_plain.extensions << "json"
MIME::Types.index_extensions text_plain