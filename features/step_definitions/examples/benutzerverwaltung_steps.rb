# -*- encoding : utf-8 -*-

Angenommen /^ein Benutzer hat aus der leihs 2.0-Datenbank den Level 1 auf einem Gerätepark$/ do
  step "I am logged in as '%s' with password 'password'" % "assist"
  ar = @user.access_rights.where(:access_level => 1).first
  ar.should_not be_nil
  @inventory_pool = ar.inventory_pool
end

Dann /^gilt er in leihs 3.0 als Level 2 für diesen Gerätepark$/ do
  @user.has_at_least_access_level(2, @inventory_pool).should be_true
end

Angenommen /^man ist Inventar\-Verwalter oder Ausleihe\-Verwalter$/ do
  ar = @user.access_rights.where(:access_level => [2, 3]).first
  ar.should_not be_nil
  @inventory_pool = ar.inventory_pool
end

Dann /^findet man die Benutzeradministration im Bereich "Administration" unter "Benutzer"$/ do
  step 'I follow "Admin"'
  step 'I follow "%s"' % _("Users")
end

Dann /^sieht man eine Liste aller Benutzer$/ do
  c = User.count
  page.should have_content("List of %d Users" % c)
end

Dann /^man kann filtern nach den folgenden Eigenschaften: gesperrt$/ do
  step 'I follow "%s"' % _("Customer")
  wait_until { all(".loading", :visible => true).empty? }

  find("[ng-model='suspended']").click
  wait_until { all(".loading", :visible => true).empty? }
  c = @inventory_pool.suspended_users.customers.count
  page.should have_content("List of %d Users" % c)

  find("[ng-model='suspended']").click
  wait_until { all(".loading", :visible => true).empty? }
  c = @inventory_pool.users.customers.count
  page.should have_content("List of %d Users" % c)
end

Dann /^man kann filtern nach den folgenden Rollen:$/ do |table|
  table.hashes.each do |row|
    step 'I follow "%s"' % row["tab"]
    role = row["role"]
    c = case role
          when "admins"
            User.admins
          when "unknown"
            User.where("users.id NOT IN (#{@inventory_pool.users.select("users.id").to_sql})")
          when "customers", "lending_managers", "inventory_managers"
            @inventory_pool.users.send(role)
          else
            User.scoped
        end.count
    wait_until { all(".loading", :visible => true).empty? }
    page.should have_content("List of %d Users" % c)
  end
end

Dann /^man kann für jeden Benutzer die Editieransicht aufrufen$/ do
  step 'I follow "%s"' % "All"
  el = find(".list ul.user")
  page.execute_script '$(":hidden").show();'
  el.find(".actions .alternatives .button .icon.user")
end

Dann /^man kann einen neuen Benutzer erstellen$/ do
  find(".top .content_navigation .button .icon.user")
end

####################################################################

Angenommen /^man editiert einen Benutzer$/ do
  @customer = @inventory_pool.users.customers.first
  visit edit_backend_inventory_pool_user_path(@inventory_pool, @customer)
end

Angenommen /^man nutzt die Sperrfunktion$/ do
  find("[ng-model='user.access_right.suspended_until']").set((Date.today+1.month).strftime("%d.%m.%Y"))
end

Dann /^muss man den Grund der Sperrung eingeben$/ do
  find("[ng-model='user.access_right.suspended_reason']").set("this is the reason")
end

Dann /^man muss das Enddatum der Sperrung bestimmen$/ do
  find(".content_navigation > button.green").click
  wait_until { find(".button.white", :text => _("Edit %s") % _("User")) }
  current_path.should == backend_inventory_pool_user_path(@inventory_pool, @customer)
  @inventory_pool.suspended_users.find_by_id(@customer.id).should_not be_nil
  @customer.access_right_for(@inventory_pool).suspended?.should be_true
end

Dann /^sofern der Benutzer gesperrt ist, kann man die Sperrung aufheben$/ do
  visit edit_backend_inventory_pool_user_path(@inventory_pool, @customer)
  find("[ng-model='user.access_right.suspended_until']").set("")
  find(".content_navigation > button.green").click
  wait_until { find(".button.white", :text => _("Edit %s") % _("User")) }
  current_path.should == backend_inventory_pool_user_path(@inventory_pool, @customer)
  @inventory_pool.suspended_users.find_by_id(@customer.id).should be_nil
  @inventory_pool.users.find_by_id(@customer.id).should_not be_nil
  @customer.access_right_for(@inventory_pool).suspended?.should be_false
end

####################################################################

Angenommen /^ein Benutzer erscheint in einer Benutzerliste$/ do
  step 'man ist Inventar-Verwalter oder Ausleihe-Verwalter'
  step 'findet man die Benutzeradministration im Bereich "Administration" unter "Benutzer"'
  step 'I follow "%s"' % _("Customer")
  find(".list ul.user .user_name")
end

Dann /^sieht man folgende Informationen in folgender Reihenfolge: Vorname, Name, Telefonnummer, Rolle, Sperr\-Status$/ do
  el = find(".list ul.user")
  el.find(".user_name + .phone + .role + .suspended_status")
end

####################################################################

Dann /^sieht man als Titel den Vornamen und Namen des Benutzers, sofern bereits vorhanden$/ do
  find(".top h1", :text => @customer.to_s)
end

Dann /^sieht man die folgenden Daten des Benutzers in der folgenden Reihenfolge:$/ do |table|
  values = table.hashes.map do |x|
    _(x[:en])
  end
  (page.text =~ Regexp.new(values.join('.*'), Regexp::MULTILINE)).should_not be_nil
end

Dann /^sieht man die Sperrfunktion für diesen Benutzer$/ do
  find("[ng-model='user.access_right.suspended_until']")
end

Dann /^sofern dieser Benutzer gesperrt ist, sieht man Grund und Dauer der Sperrung$/ do
  if @customer.access_right_for(@inventory_pool).suspended?
    find("[ng-model='user.access_right.suspended_reason']")
  end
end

Dann /^man kann die Informationen ändern, sofern es sich um einen externen Benutzer handelt$/ do
  if @customer.authentication_system.class_name == "DatabaseAuthentication"
    find(".editable input[ng-model='user.lastname']")
    find(".editable input[ng-model='user.firstname']")
    find(".editable input[ng-model='user.address']")
    find(".editable input[ng-model='user.zip']")
    find(".editable input[ng-model='user.city']")
    find(".editable input[ng-model='user.country']")
    find(".editable input[ng-model='user.phone']")
    find(".editable input[ng-model='user.email']")
  end
end

Dann /^man kann die Informationen nicht verändern, sofern es sich um einen Benutzer handelt, der über ein externes Authentifizierungssystem eingerichtet wurde$/ do
  if @customer.authentication_system.class_name != "DatabaseAuthentication"
    find("div:not(.editable) [ng-model='user.lastname']")
    find("div:not(.editable) [ng-model='user.firstname']")
    find("div:not(.editable) [ng-model='user.address']")
    find("div:not(.editable) [ng-model='user.zip']")
    find("div:not(.editable) [ng-model='user.city']")
    find("div:not(.editable) [ng-model='user.country']")
    find("div:not(.editable) [ng-model='user.phone']")
    find("div:not(.editable) [ng-model='user.email']")
  end
end

Dann /^man sieht die Rollen des Benutzers und kann diese entsprechend seiner Rolle verändern$/ do
  find(".editable select[ng-model='user.access_right.role_name']")
end

Dann /^man kann die vorgenommenen Änderungen abspeichern$/ do
  find(".content_navigation > button.green").click
end