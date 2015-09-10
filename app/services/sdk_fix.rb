class SdkFix

	class << self

		def create_company_with_prefix(company_name:, website: nil, favicon: nil, prefix:)

			company = create_company(name: company_name, website: website, favicon: favicon)

			add_prefix_to_company(prefix: prefix, company: company.id)

		end

		def create_company(name:, website: nil, favicon: nil)

			return "Sorry, a company already exists with that name." if AndroidSdkCompany.find_by_name(name).present?

			if website.nil?

				tmp_website = SdkCompanyServiceWorker.new.google_search(name)

				puts tmp_website
				puts "does that website look right? [y/n]"

				answer = gets.chomp

				if answer == 'y'
					website = tmp_website
				elsif answer == 'n'
					puts 'please manually input a website'
					website = gets.chomp
				else
					return 'failed to create company'
				end

			end

			website = SdkCompanyServiceWorker.new.httpify(website)

			favicon = SdkCompanyServiceWorker.new.get_favicon(website) if favicon.nil?

			AndroidSdkCompany.create(name: name, website: website, favicon: favicon)

		end

		def add_prefix_to_company(prefix:, company:)

			prefix = prefix.is_a?(String) ? AndroidSdkPackagePrefix.find_by_prefix(prefix) : AndroidSdkPackagePrefix.find_by_id(prefix)

			return "No such prefix exists." if prefix.blank?

			company = company.is_a?(String) ? AndroidSdkCompany.find_by_name(company) : AndroidSdkCompany.find_by_id(company)

			return "No such company exists." if company.blank?

			prefix.android_sdk_company = company

			prefix.save

			prefix.android_sdk_packages.each do |package|

				AndroidSdkPackagesApkSnapshot.where(android_sdk_package: package).each do |a|

					as = ApkSnapshot.find(a.apk_snapshot_id)

					AndroidSdkCompaniesApkSnapshot.find_or_create_by(android_sdk_company: company, apk_snapshot: as)

				end

			end

		end

		def remove_prefix_from_company(prefix:, company:)

			prefix = prefix.is_a?(String) ? AndroidSdkPackagePrefix.find_by_prefix(prefix) : AndroidSdkPackagePrefix.find_by_id(prefix)

			company = company.is_a?(String) ? AndroidSdkCompany.find_by_name(company) : AndroidSdkCompany.find_by_id(company)

			prefix.android_sdk_company = nil

			prefix.save

			prefix.android_sdk_packages.each do |package|

				AndroidSdkPackagesApkSnapshot.where(android_sdk_package: package).each do |a|

					as = ApkSnapshot.find(a.apk_snapshot_id)

					ascaa = AndroidSdkCompaniesApkSnapshot.where(android_sdk_company: company, apk_snapshot: as).first

					ascaa.delete if ascaa.present?

				end

			end

		end

	end

end