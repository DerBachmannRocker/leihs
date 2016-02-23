Feature: Exporting the data to a CSV-File

#Pretty final... maybe some more fields will be exported, no other change
  Scenario: Export data
    When I access the procurement overview
    Then I can export the shown information
    And the following fields are exported
      | Budget Period                 |
      | Procurement Group             |
      | Article                       |
      | Article nr. / Producer nr.    |
      | Replacement / New             |
      | New                           |
      | Requested quantity            |
      | Approved quantity             |
      | Order quantity                |
      | Price                         |
      | Total                         |
      | Priority                      |
      | Motivation                    |
      | Supplier                      |
      | Inspection Comment            |
      | Receiver                      |
      | Point of Delivery             |
      | Organisation Unit of Receiver |
      | State                         |
