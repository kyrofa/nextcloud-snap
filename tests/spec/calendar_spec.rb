feature "Testing the calendar" do
	scenario "install and remove" do
		# First of all, login
		assert_login
		
		install_contacts_app
		uninstall_contacts_app
	end

	protected

	def assert_login
		visit "/"
		fill_in "User", with: "admin"
		fill_in "Password", with: "admin"
		click_button "Log in"
		expect(page).to have_content "Documents"
	end
	
	def install_contacts_app
		# Go through the user flow to install the calendar app
		find("#settings").click
		expect(page).to have_content "Apps"
		click_link "Apps"
		
		expect(page).to have_content "Organization"
		click_link "Organization"
		
		expect(page).to have_content "Contacts"
		within "#app-contacts" do
			click_button "Enable"
		end
		
		assert_contacts_installed
	end
	
	def uninstall_contacts_app
		# Go through the user flow to uninstall the calendar app
		find("#settings").click
		expect(page).to have_content "Apps"
		click_link "Apps"
		
		expect(page).to have_content "Organization"
		click_link "Organization"
		
		expect(page).to have_content "Contacts"
		within "#app-contacts" do
			click_button "Disable"
		end
		
		assert_contacts_not_installed
	end
	
	def assert_contacts_installed
		expect(page).to have_selector :xpath, "//div[@id='header']//a[contains(@href, 'contacts')]"
	end
	
	def assert_contacts_not_installed
		expect(page).not_to have_selector :xpath, "//div[@id='header']//a[contains(@href, 'contacts')]"
	end
end
