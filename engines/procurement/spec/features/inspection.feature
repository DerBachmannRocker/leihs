Feature: Inspection (state-behaviour described in seperate feature-file)

  @inspection
  Scenario: What to see in section "Requests" as inspector
    Given I am Barbara
    And several requests exist
    When I navigate to the requests overview page
    Then the current budget period is selected
    And only my groups are selected
    And all organisations are selected
    And both priorities are selected
    And all states are selected
    And the search field is empty
    And the checkbox "Only show my own request" is not marked
    And I see the headers of the colums of the overview
    And I see the amount of requests which are listed is 1
    And I see the current budget period
    And I see the requested amount per budget period
    And I see the requested amount per group of each budget period
    And I see the budget limits of all groups
    And I see the total of all ordered amounts of each groups
    And I see the total of all ordered amounts of a budget period
    And I see the percentage of budget used compared to the budget limit of my group
    And I see when the requesting phase of this budget period ends
    And I see when the inspection phase of this budget period ends
    And I see all groups
    And I see the following request information
      | article name          |
      | name of the requester |
      | department            |
      | organisation          |
      | price                 |
      | requested amount      |
      | approved amount       |
      | ordered amount        |
      | total amount          |
      | priority              |
      | state                 |

  @inspection
  Scenario: Using the filters as inspector
    Given I am Barbara
    And templates for my group exist
    And several requests exist for the current budget period
    And two requests have been created by myself
    And one request has been created by Roger
    When I navigate to the requests overview page
    And I select "only show my own requests"
    And I select the current budget period
    And I select all groups
    And I select all organisations
    And I select both priorities
    And I select all states
    And I enter leave the search string empty
    Then the list of requests is adjusted immediately
    And I see both my requests
    And the amount of requests found is shown as 2
    When I navigate to the templates page of my group
    And I navigate back to the request overview page
    Then the filter settings have not changed

  @inspection
  Scenario: Creating a request as inspector
    Given I am Barbara
    And a receiver exists
    And a point of delivery exists
    When I want to create a new request
    And I fill in the following fields
      | Article                      |
      | Article nr. / Producer nr.   |
      | Supplier                     |
      | Motivation                   |
      | Price                        |
      | Requested quantity           |
      | Approved quantity            |
    Then the "requested quantity" is copied to the field "Order quantity"
    And I change the amount of the "Order quantity"
    And the ordered amount and the price are multiplied and the result is shown
    When I upload a file
    And I choose the name of a receiver
    And I choose the point of delivery
    And I choose the option "High" of the field "Priority"
    And I choose the option "New" of the field "Replacement/New"
    And I see the status "New"
    And I click on save
    Then I see a success message
    And the request with all given information was created successfully in the database

  @inspection
  Scenario: Creating a request for another user
    Given I am Barbara
    When I navigate to the requests overview page
    And I press on the Userplus icon of a group I am inspecting
    Then I am navigated to the requester list
    When I pick a requester
    Then I am navigated to the new request page for this username
    When I fill in all mandatory information
    And I click on save
    Then I see a success message
    And the request with all given information was created successfully in the database

  @inspection
  Scenario: Give Reason when Partially Excepting or Denying
    Given I am Barbara
    And several requests exists
    And the requested amount is 2
    When I am navigated to the requests page
    And I set the approved quantity to 0
    Then the field "inspection comment" is marked red
    And I can not save the request
    When I enter the inspection comment
    And I click on save
    Then I see a success message
    And the status is set to "Denied"
    And the request with all given information was saved successfully in the database
    When I delete the inspection comment
    And I change the approved quantity to 1
    Then the field "inspection comment" is marked red
    And I can not save the request
    When I enter the inspection comment
    And I click on save
    Then I see a success message
    And the status is set to "Partially Approved"
    And the request with all given information was saved successfully in the database

  @inspection
  Scenario: Moving request to another budget period as inspector
    Given I am Barbara
    And the current budget period is in inspection phase
    And there is a future budget period
    And there is a budget period which has already ended
    And several requests for my inspection group and the current budget period exist
    When I am navigated to the requests page
    Then I can not move the request to the old budget period
    When I move the request to the future budget period
    Then I see a success message
    And the changes are saved successfully to the database
    And I can not save the data

  @inspection
  Scenario: Moving request as inspector to another group
    Given I am Barbara
    And several groups exist
    And the current budget period is in inspection phase
    And several requests for my inspection group and the current budget period exist
    When I navigate to the requests page
    And I move the request to the other group where I am not inspector
    Then I see a success message
    And the changes are saved successfully to the database
    And the following information is deleted from the request
    | Approved quantity  |
    | Order quantity     |
    | Inspection comment |
