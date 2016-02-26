module ApplicationHelper
    def url_domain(url)
        Addressable::URI.parse(url).host if url
    end

    def bootstrap_class_for flash_type
       { success: "success", error: "error", alert: "warning", notice: "info" }[flash_type.to_sym] || flash_type.to_s
    end
end
