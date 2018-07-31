feature "Testing calendar app" do
	before :each do
		# The calendar tries to use navigator.registerProtocolHandler for
		# handling webcal links, but this is unsupported by webkit. Ignore
		# javascript errors for these tests. This is deprecated, but there
		# doesn't seem to be any other way of doing this, and we don't want to
		# disable them for everything.
		page.driver.browser.set_raise_javascript_errors false

		login
		install_calendar_app
	end
	
	after :each do
		uninstall_calendar_app
	end
	
	scenario "add and remove event" do
		visit_calendar_app
		
		# Create a new event on the 1st of the month
		calendar = find("div#calendar")
		first_week = calendar.first("div.fc-week")
		first_day = first_week.first("div.fc-day")
		first_day.click		
		
		# Wait for the ajax request to go through
		expect(page).to have_css "div.modal-dialog", wait: 10
		within :xpath, "//div[@class='modal-dialog']//form[contains(@class, 'events')]" do
			fill_in "title", with: "Test Event"
			click_button "Create"
		end
		
		# Wait for the event to be created
		expect(page).to have_content "Test Event"
	end

	protected

	def login
		visit "/"
		fill_in "User", with: "admin"
		fill_in "Password", with: "admin"
		click_button "Log in"
		expect(page).to have_content "Documents"
	end
	
	def install_calendar_app
		# Go through the user flow to install the calendar app
		find("div#settings").click
		expect(page).to have_content "Apps", wait: 10
		click_link "Apps"
		
		expect(page).to have_content "Office & text", wait: 10
		click_link "Office & text"
		
		expect(page).to have_content "Calendar", wait: 10
		within "#app-calendar" do
			click_button "Enable"
		end
		
		assert_calendar_installed
	end
	
	def uninstall_calendar_app
		# Go through the user flow to uninstall the calendar app
		find("#settings").click
		expect(page).to have_content "Apps", wait: 10
		click_link "Apps"
		
		expect(page).to have_content "Office & text", wait: 10
		click_link "Office & text"
		
		expect(page).to have_content "Calendar", wait: 10
		within "#app-calendar" do
			click_button "Disable"
		end
		
		assert_calendar_not_installed
	end
	
	def assert_calendar_installed
		expect(page).to have_selector :xpath, "//div[@id='header']//a[contains(@href, 'calendar')]", wait: 10
	end
	
	def assert_calendar_not_installed
		expect(page).not_to have_selector :xpath, "//div[@id='header']//a[contains(@href, 'calendar')]", wait: 10
	end
	
	def visit_calendar_app
		# Click the calendar app icon
		find(:xpath, "//div[@id='header']//a[contains(@href, 'calendar')]").click
		expect(page).to have_content "Personal"
	end
end
