require 'jekyll'
require 'jekyll/pagination'

module Jekyll
  class PaginationMulti < Pagination
    def self.generate(site)
      # Ambil daftar file yang akan dipaginasi dari config
      paginate_files = Array(site.config['paginate_files'] || site.config['paginate_file'] || 'index.html')

      paginate_files.each do |page_name|
        paginate_page(site, page_name)
      end
    end

    def self.paginate_page(site, page_name)
      site.pages.each do |page|
        next unless page.name == page_name || page.url.end_with?(page_name)
        Pager.pagination_enabled?(site.config, page) or next

        all_posts = site.site_payload['site']['posts'].docs
        paginate_path = page.dir
        per_page = site.config['paginate'].to_i

        pager = Pager.new(site, 1, all_posts, per_page, paginate_path)
        page.data['paginator'] = pager

        (2..pager.total_pages).each do |num_page|
          newpage = Page.new(site, site.source, page.dir, page.name)
          newpage.pager = Pager.new(site, num_page, all_posts, per_page, paginate_path)
          newpage.dir = Pager.paginate_path(site, num_page)
          site.pages << newpage
        end
      end
    end
  end
end

# Hook ke Jekyll
Jekyll::Hooks.register :site, :post_read do |site|
  Jekyll::PaginationMulti.generate(site)
end
