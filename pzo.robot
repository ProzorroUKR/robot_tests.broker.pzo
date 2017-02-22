*** Settings ***
Library  Selenium2Screenshots
Library  String
Library  DateTime
Library  pzo_service.py

*** Variables ***
${locator.tenderId}                                            xpath=//*[contains(@class, 'tender-id')]//*[@class='value']
${locator.title}                                               xpath=//*[@class='page-title']
${locator.description}                                         xpath=//*[@class='tender-info-wrapper info-wrapper']//*[@class='description']
${locator.minimalStep.amount}                                  xpath=//*[contains(@class, 'minimal-step')]//*[@class='value']
${locator.procuringEntity.name}                                xpath=//*[contains(@class, 'legal-name')]//*[@class='value']
${locator.value.amount}                                        xpath=//*[contains(@class, 'budget')]//*[@class='value']
${locator.enquiryPeriod.startDate}                             xpath=//*[contains(@class, 'enquiry-period')]//*[@class='value']
${locator.enquiryPeriod.endDate}                               xpath=//*[contains(@class, 'enquiry-period')]//*[@class='value']
${locator.tenderPeriod.startDate}                              xpath=//*[contains(@class, 'tender-period')]//*[@class='value']
${locator.tenderPeriod.endDate}                                xpath=//*[contains(@class, 'tender-period')]//*[@class='value']

${locator.items[0].deliveryDate.endDate}                       xpath=//*[contains(@class, 'delivery-period')]//span[@class='end-date']
#${locator.items[0].deliveryLocation.latitude}                  id=delivery_latitude0
#${locator.items[0].deliveryLocation.longitude}                 id=delivery_longitude0
${locator.items[0].deliveryAddress.countryName}                xpath=//p[@class='delivery']//span[@class='country']
${locator.items[0].deliveryAddress.postalCode}                 xpath=//p[@class='delivery']//span[@class='postcode']
${locator.items[0].deliveryAddress.region}                     xpath=//p[@class='delivery']//span[@class='region']
${locator.items[0].deliveryAddress.locality}                   xpath=//p[@class='delivery']//span[@class='locality']
${locator.items[0].deliveryAddress.address}                    xpath=//p[@class='delivery']//span[@class='street-address']
${locator.items[0].description}                                xpath=//*[contains(@class, 'item-info-wrapper')]//p[@class='title']//*[@class='value']
${locator.items[0].classification.scheme}                      xpath=(//p[@class='classification'])[1]//*[@class='key']
${locator.items[0].classification.id}                          xpath=(//p[@class='classification'])[1]//*[@class='value']
#${locator.items[0].classification.description}                xpath=(//p[@class='classification'])[1]//*[@class='value']
${locator.items[0].additionalClassifications[0].scheme}        xpath=(//p[@class='classification'])[2]//*[@class='key']
${locator.items[0].additionalClassifications[0].id}            xpath=(//p[@class='classification'])[2]//*[@class='value']
#${locator.items[0].additionalClassifications[0].description}  xpath=(//p[@class='classification'])[2]//*[@class='value']

#${locator.items[0].unit.code}                                  xpath=(//*[@class='panel-heading'])[1]//*[contains(@class, 'quantity')]
${locator.items[0].quantity}                                   xpath=//p[@class='quantity']//*[@class='value']

${locator.questions[0].title}                                  xpath=//div[@class='question-info-wrapper info-wrapper']//p[@class='title']//*[@class='value']
${locator.questions[0].description}                            xpath=//p[@class='description']//*[@class='value']
${locator.questions[0].date}                                   xpath=//p[@class='data-published']//*[@class='value']
${locator.questions[0].answer}                                 xpath=//p[@class='answer']//*[@class='value']
${locator.status}                                              xpath=//*[contains(@class, 'hidden opstatus')]
${tender_page_prefix}=                                         http://dev.pzo.com.ua/tender/view?id=
${tender_sync_prefix}=                                         http://dev.pzo.com.ua/utils/tender-sync?pk=
${tender_sync_postfix}=                                        ?psw=369369

*** Keywords ***
Підготувати дані для оголошення тендера
  [Arguments]  @{ARGUMENTS}
  ${INITIAL_TENDER_DATA}=  test_tender_data
  [return]   ${INITIAL_TENDER_DATA}

Підготувати клієнт для користувача
  [Arguments]  ${username}
  [Documentation]  Відкрити браузер, створити об’єкт api wrapper, тощо
#  Sleep  1
#  Open Browser  ${USERS.users['${username}'].homepage}  ${USERS.users['${username}'].browser}  alias=${username}
  Open Browser  ${BROKERS['pzo'].homepage}  ${USERS.users['${username}'].browser}  alias=${username}
  Set Window Size  @{USERS.users['${username}'].size}
  Set Window Position  @{USERS.users['${username}'].position}
  Login  ${username}

Login
  [Arguments]  ${username}
  Wait Until Element Is Visible  xpath=//*[contains(@data-language, '1')]  10
  Click Link    xpath=//*[contains(@data-language, '1')]

  Wait Until Element Is Visible  xpath=//*[contains(@class, 'btn btn-lg btn-default btn-custom waves-effect waves-light')]  10
  Click Link    xpath=//*[contains(@class, 'btn btn-lg btn-default btn-custom waves-effect waves-light')]
  Sleep    1
  Wait Until Page Contains Element   id=loginform-email   20
  Input text   id=loginform-email      ${USERS.users['${username}'].login}
  Input text   id=loginform-password      ${USERS.users['${username}'].password}
  # Click Button   xpath=//*[@type='submit']
  Click Button   xpath=//*[@class='btn btn-lg w-lg-x2 btn-success js-submit-btn']
  Wait Until Page Contains          Активні   20
  #Go To  ${USERS.users['${username}'].homepage}

Створити тендер
  [Arguments]  ${user}  ${tender_data}
  #${tender_data}=   Add_data_for_GUI_FrontEnds  ${ARGUMENTS[1]}
  ${tender_data}=   procuring_entity_name  ${tender_data}
  ${items}=         Get From Dictionary   ${tender_data.data}               items
  ${title}=         Get From Dictionary   ${tender_data.data}               title
  ${description}=   Get From Dictionary   ${tender_data.data}               description
  ${budget}=        Get From Dictionary   ${tender_data.data.value}         amount
  ${budget}=        Convert To String     ${budget}
  ${step_rate}=     Get From Dictionary   ${tender_data.data.minimalStep}   amount
  ${step_rate}=     Convert To String     ${step_rate}
  ${items_description}=   Get From Dictionary   ${items[0]}         description
  ${quantity}=      Get From Dictionary   ${items[0]}                        quantity
  ${quantity}=      Convert To String     ${quantity}
  ${cpv}=           Get From Dictionary   ${items[0].classification}         id
  ${unit}=          Get From Dictionary   ${items[0].unit}                   name
  ${latitude}       Get From Dictionary   ${items[0].deliveryLocation}    latitude
  ${longitude}      Get From Dictionary   ${items[0].deliveryLocation}    longitude
  ${postalCode}    Get From Dictionary   ${items[0].deliveryAddress}     postalCode
  ${streetAddress}    Get From Dictionary   ${items[0].deliveryAddress}     streetAddress
  ${deliveryDate}   Get From Dictionary   ${items[0].deliveryDate}        endDate
  ${start_date}=    Get From Dictionary   ${tender_data.data.tenderPeriod}   startDate
  ${start_date}=    convert_datetime_for_delivery   ${start_date}
  ${start_date} =   Convert Date 	${start_date} 	%d.%m.%Y %H:%M
  ${end_date}=      Get From Dictionary   ${tender_data.data.tenderPeriod}   endDate
  ${end_date}=      convert_datetime_for_delivery   ${end_date}
  ${end_date} =   Convert Date 	${end_date} 	%d.%m.%Y %H:%M
  ${enquiry_start_date}=    Get From Dictionary   ${tender_data.data.enquiryPeriod}   startDate  
  ${enquiry_start_date}=    convert_datetime_for_delivery   ${enquiry_start_date}
  ${enquiry_start_date} =   Convert Date 	${enquiry_start_date} 	%d.%m.%Y %H:%M
  ${enquiry_end_date}=      Get From Dictionary   ${tender_data.data.enquiryPeriod}   endDate
  ${enquiry_end_date}=      convert_datetime_for_delivery   ${enquiry_end_date}
  ${enquiry_end_date} =   Convert Date 	${enquiry_end_date} 	%d.%m.%Y %H:%M
  
  Selenium2Library.Switch Browser    ${user}
  Go To                             ${USERS.users['${user}'].homepage}
  Wait Until Page Contains          Мої закупівлі   10
  Sleep  1
  Click Element                     xpath=//*[contains(@href, '/tender/create')]
  Sleep  1
  Wait Until Page Contains          Створення закупівлі  10
  Input text    id=tenderbelowthresholdform-title                 ${title}
  Input text    id=tenderbelowthresholdform-description            ${description}
# Input text    id=tenderbelowthresholdform-value_amount                  ${budget}
  Click Element                     id=tenderbelowthresholdform-value_added_tax_included
# Input text    id=TenderForm_op_min_step_amount            ${step_rate}
  Input text    id=tenderbelowthresholdform-enquiry_period_start_date        ${enquiry_start_date}
  Input text    id=tenderbelowthresholdform-enquiry_period_end_date          ${enquiry_end_date}
  Input text    id=tenderbelowthresholdform-tender_period_start_date        ${start_date}
  Input text    id=tenderbelowthresholdform-tender_period_end_date          ${end_date}
 
  Select Checkbox  id=tenderbelowthresholdform-quick_mode

  Click Element                      xpath=//*[contains(@href, '#collapseLots')]
  Input text                         xpath=//div[contains(@class, 'form-group field-lotform')]//input[contains(@id, '-title')]  ${items_description}
  Input text                         xpath=//div[contains(@class, 'row js-budget-wrapper')]//input[contains(@id, '-value_amount')]  ${budget}
  Input text                         xpath=//div[contains(@class, 'row js-budget-wrapper')]//input[contains(@id, '-min_step_amount')]  ${step_rate}

  Додати предмет   ${items[0]}   0
  Run Keyword if   '${mode}' == 'multi'   Додати багато предметів   items
  Sleep  1

#  Select Checkbox  id=TenderForm_op_mode
#  Wait Until Page Contains Element   xpath=//*[@type='submit']

  Click Element   xpath=//*[@id='submitBtn']
  Sleep  1
  Wait Until Page Contains   Закупівля створена, дочекайтесь опублікування на сайті уповноваженого органу.   10
  Click Element   xpath=//div[contains(@class, 'jconfirm-box')]//button[contains(@class, 'btn btn-default waves-effect waves-light btn-lg')]

  Sleep   5
  Reload Page
  ${tender_UAid}=  Get Text  xpath=//*[contains(@class, 'tender-id')]//*[@class='value']
  #Log To Console  ${tender_UAid}

  ${Ids}=   Convert To String   ${tender_UAid}
  Save Tender ID
  Log  ${Ids}
  [return]  ${Ids}

Додати предмет
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  item
  ...      ${ARGUMENTS[1]} ==  ${INDEX}
  ${description}=   Get From Dictionary   ${ARGUMENTS[0]}              description
  ${cpv_id}=        Get From Dictionary   ${ARGUMENTS[0].classification}              id
  ${dkpp_id}=       Get From Dictionary   ${ARGUMENTS[0].additionalClassifications[0]}   id
  ${unit}=          Get From Dictionary   ${ARGUMENTS[0].unit}    name
  ${quantity}=      Get From Dictionary   ${ARGUMENTS[0]}         quantity
  ${quantity}=      Convert To String     ${quantity}
  ${region}=        Get From Dictionary   ${ARGUMENTS[0].deliveryAddress}  region
  ${locality}=      Get From Dictionary   ${ARGUMENTS[0].deliveryAddress}  locality
  ${street}=        Get From Dictionary   ${ARGUMENTS[0].deliveryAddress}  streetAddress
  ${code}=          Get From Dictionary   ${ARGUMENTS[0].deliveryAddress}  postalCode
  ${code}=          Convert To String     ${code}
  ${delivery_end}=  Get From Dictionary   ${ARGUMENTS[0].deliveryDate}  endDate
  ${delivery_end}=  convert_datetime_for_delivery  ${delivery_end}
  ${delivery_end} =   Convert Date 	${delivery_end} 	%d.%m.%Y %H:%M

  Sleep  2
  Input text                         xpath=//div[contains(@class, 'tab-pane active item-wrapper js-item')]//input[contains(@id, '-description')]  ${description}
  Input text                         xpath=//div[contains(@class, 'tab-pane active item-wrapper js-item')]//input[contains(@id, '-quantity')]  ${quantity}
  Select From List By Label          xpath=//div[contains(@class, 'tab-pane active item-wrapper js-item')]//select[contains(@id, '-unit_id')]  ${unit}
  
#  Sleep  2
  Click Element                      xpath=//div[contains(@class, 'tab-pane active item-wrapper js-item')]//a[contains(@href, '#classification')]
  Wait Until Element Is Visible      xpath=//div[contains(@id, 'classification-modal')]//h4[contains(@id, 'classificationModalLabel')]
  Sleep  1
  Input text                         xpath=//div[contains(@id, 'classification-modal')]//input[@class='form-control js-input']  ${cpv_id}
  Press key                          xpath=//div[contains(@id, 'classification-modal')]//input[@class='form-control js-input']  \\13
  Wait Until Page Contains Element   xpath=//div[contains(@id, 'classification-modal')]//strong[contains(., '${cpv_id}')]  10
  Click Element                      xpath=//div[contains(@id, 'classification-modal')]//i[@class='jstree-icon jstree-checkbox']
  Click Element                      xpath=//div[contains(@id, 'classification-modal')]//button[contains(@class, 'btn btn-default waves-effect waves-light js-submit')]
  Sleep  1
  
  Click Element                      xpath=//div[contains(@class, 'tab-pane active item-wrapper js-item')]//a[contains(@href, '#additionalclassification')]
  Wait Until Element Is Visible      xpath=//div[contains(@id, 'additional-classification-modal')]//h4[contains(@id, 'additionalClassificationModalLabel')]
  Sleep  1
  Input text                         xpath=//div[contains(@id, 'additional-classification-modal')]//input[@class='form-control js-input']  ${dkpp_id}
  Press key                          xpath=//div[contains(@id, 'additional-classification-modal')]//input[@class='form-control js-input']  \\13
  Wait Until Page Contains Element   xpath=//div[contains(@id, 'additional-classification-modal')]//strong[contains(., '${dkpp_id}')]  20
  Sleep  3
  Click Element                      xpath=//div[contains(@id, 'additional-classification-modal')]//i[@class='jstree-icon jstree-checkbox']
  Click Element                      xpath=//div[contains(@id, 'additional-classification-modal')]//button[contains(@class, 'js-submit')]

  Sleep  1
  # Execute Javascript  $('[name*="op_classification_id"]').eq(${ARGUMENTS[1]}).attr('value', '6272')
  # Execute Javascript  $('[name*="op_additional_classification_ids"]').eq(${ARGUMENTS[1]}).attr('value', '11911')

  Select Checkbox                    //div[contains(@class, 'tab-pane active item-wrapper js-item')]//*[@type='checkbox'][contains(@id, '-delivery')]

# Sleep 1
# Wait For Element Is Visible        xpath=(//*[@data-type='item'])[last()]//select[contains(@id, '_op_delivery_address_region_id')]  10
  Select From List By Label          //div[contains(@class, 'toggle-wrapper js-toggle-wrapper')]//select[contains(@id, '-delivery_region_id')]  ${region}

  Sleep  1
#  ${has_locality}=  Run Keyword And Return Status  Element Should Contain  xpath=(//*[@data-type='item'])[last()]//select[contains(@id, '_op_delivery_address_locality_id')]  ${locality}
#  Run Keyword If  ${has_locality}  Select From List By Label  xpath=(//*[@data-type='item'])[last()]//select[contains(@id, '_op_delivery_address_locality_id')]  ${locality}

  Input Text                        xpath=//div[contains(@class, 'toggle-wrapper js-toggle-wrapper')]//input[contains(@id, '-delivery_locality')]  ${locality}
  Input Text                        xpath=//div[contains(@class, 'toggle-wrapper js-toggle-wrapper')]//input[contains(@id, '-delivery_street_address')]  ${street}
  Input Text                        xpath=//div[contains(@class, 'toggle-wrapper js-toggle-wrapper')]//input[contains(@id, '-delivery_postal_code')]  ${code}
  Input Text                        xpath=//div[contains(@class, 'toggle-wrapper js-toggle-wrapper')]//input[contains(@id, '-delivery_end_date')]  ${delivery_end}


Додати багато предметів
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  items
  ${Items_length}=   Get Length   ${items}
  : FOR    ${INDEX}    IN RANGE    1    ${Items_length}
  \   Click Element   xpath=//*[contains(@class, 'js-dynamic-form-add')]
  \   Додати предмет   ${items[${INDEX}]}   ${INDEX}

Клацнути і дочекатися
  [Arguments]  ${click_locator}  ${wanted_locator}  ${timeout}
  [Documentation]
  ...      click_locator: Where to click
  ...      wanted_locator: What are we waiting for
  ...      timeout: Timeout
  Click Element  ${click_locator}
  Wait Until Page Contains Element  ${wanted_locator}  ${timeout}

Шукати і знайти
  Клацнути і дочекатися  xpath=//button[contains(@class, 'js-submit-btn')]  xpath=(//div[@id='tender-list'])//a[contains(@href, '/tender/')]  5

Load And Check Text
  [Arguments]  ${url}  ${wanted_text}
  Go To  ${url}
  Page Should Contain  ${wanted_text}

Load And Wait Text
  [Arguments]  ${url}  ${wanted_text}  ${retries}
  Wait Until Keyword Succeeds  ${retries}x  200ms  Load And Check Text  ${url}  ${wanted_text}

Пошук тендера по ідентифікатору
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER_UAID}
  Selenium2Library.Switch browser   ${ARGUMENTS[0]}

  #Log to Console  ${ARGUMENTS[1]}

#  ${tender_id}=  Get From Dictionary  ${TENDER}  TENDER_ID

#  Go To                            ${BROKERS['pzo'].homepage}
  Load And Wait Text  ${BROKERS['pzo'].homepage}  Публічні закупівлі  4

  #Go To  ${BROKERS['ubiz'].homepage}
  #Wait Until Page Contains   Публічні закупівлі    20

#  sleep  1
  Wait Until Page Contains Element    id=tendersearchform-query    20

# Sleep  3  

  Input Text    id=tendersearchform-query    ${ARGUMENTS[1]}

#  Sleep  3
  ${timeout_on_wait}=  Get Broker Property By Username  ${ARGUMENTS[0]}  timeout_on_wait
  ${passed}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  ${timeout_on_wait} s  0 s  Шукати і знайти
  Run Keyword Unless  ${passed}  Fatal Error  Тендер не знайдено за ${timeout_on_wait} секунд
#  Sleep  3
#  Log To Console  ${ARGUMENTS[1]}
  Wait Until Page Contains Element    xpath=(//div[@id='tender-list'])//a[contains(@href, '/tender/')][1]    20
  Sleep  2
  Click Element    xpath=(//div[@id='tender-list'])//a[contains(@href, '/tender/')][1]
#  Sleep  1
  Wait Until Page Contains    ${ARGUMENTS[1]}   60
  Save Tender ID
#  Click Element  xpath=//span[@class='expand']
#  Wait Until Element Is Visible  ${locator.items[0].classification.id}  10
  #Sleep  1
  Capture Page Screenshot

Завантажити документ
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${filepath}
  ...      ${ARGUMENTS[2]} ==  ${TENDER_UAID}
  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
  #ubiz.Пошук тендера по ідентифікатору  ${ARGUMENTS[0]}  ${ARGUMENTS[2]}
  Open Tender
  Wait Until Page Contains  Ідентифікатор закупівлі  20
  Click Element  xpath=//a[contains(@href, '/tender/update?id=')]
  Sleep  1
  Wait Until Page Contains  Редагування закупівлі  10

  Click Element   xpath=//*[@class='panel-heading']//*[@href='#collapseDocuments']
  Sleep  1

  Click Element  xpath=//a[contains(@data-url, '/tender/get-document-form')]
  Wait Until Page Contains Element  xpath=//input[@type='file']  10
  Choose File  xpath=//input[@type='file']  ${ARGUMENTS[1]}

  Sleep  1
  Click Element   xpath=//*[@id='submitBtn']
  Sleep  1
  Wait Until Page Contains   Закупівля оновлена   10
  Click Element   xpath=//div[contains(@class, 'jconfirm-box')]//button[contains(@class, 'btn btn-default waves-effect waves-light btn-lg')]


Подати скаргу
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} ==  ${Complain}
  Fail  Не реалізований функціонал

порівняти скаргу
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${file_path}
  ...      ${ARGUMENTS[2]} ==  ${TENDER_UAID}
  Fail  Не реалізований функціонал

Подати цінову пропозицію
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} ==  ${test_bid_data}
  ${bid}=                     Get From Dictionary   ${ARGUMENTS[2].data.value}         amount
  #pzo.Оновити сторінку з тендером   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  Open Tender

  Click Element                      xpath=//a[contains(@href, '/tender/bid?id=')]
  Wait Until Page Contains           Подача пропозиції   10
  Sleep  3

  Input text                         xpath=//input[contains(@id, '-value_amount')]               ${bid}

  Click Button   xpath=//*[@class='btn btn-success btn-lg w-lg-x3 js-submit-btn']
  Wait Until Page Contains           Пропозиція створена  10


Змінити цінову пропозицію
  [Arguments]  ${username}  ${tender_uaid}  ${amount_locator}  ${new_sum}
  #ubiz.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  Open Tender
  Page Should Contain Element  xpath=//a[contains(@href, '/tender/bid?id=')]
  Sleep  3
  Click Element                xpath=//a[contains(@href, '/tender/bid?id=')]
  Wait Until Page Contains    Редагування пропозиції    10
  Sleep  2

  Input text                         xpath=//input[contains(@id, '-value_amount')]              ${new_sum}
  Click Button   xpath=//*[@class='btn btn-success btn-lg w-lg-x3 js-submit-btn']
  Wait Until Page Contains           Пропозиція відредагована  10
  Sleep  1

Завантажити документ в ставку
  [Arguments]  ${provider}  ${filepath}  ${tender_uaid}
  Open Tender
  Page Should Contain Element  xpath=//a[contains(@href, '/tender/bid?id=')]
  Sleep  3
  Click Element                xpath=//a[contains(@href, '/tender/bid?id=')]
  Wait Until Page Contains    Редагування пропозиції    10
  Sleep  2

  Click Element   xpath=//a[contains(@class, 'js-dynamic-form-add')]
  Sleep  2
  Wait Until Page Contains Element  xpath=//input[@type='file']  10
  Choose File  xpath=//input[@type='file']  ${filepath}
  Sleep  2

  Click Button   xpath=//*[@class='btn btn-success btn-lg w-lg-x3 js-submit-btn']
  Wait Until Page Contains           Пропозиція відредагована  10
  Sleep  1

#  Click Element               xpath=//a[contains(@class, 'js-items-add')]
#  Wait Until Page Contains Element  xpath=//input[@type='file']  10
#  Choose File                 xpath=//input[@type='file']  ${filepath}
#  Sleep  1
#  Click Element               xpath=//form[@id='tender-bid-form']//input[@type='submit']
#  Sleep  1
#  #ubiz.Оновити сторінку з тендером  ${provider}  ${tender_uaid}

Змінити документ в ставці
  [Arguments]  ${username}  ${filepath}  ${bidid}  ${docid}
  ${tender_name}=  Get From Dictionary  ${USERS.users['${tender_owner}'].initial_data.data}  title
  Open Tender
  Page Should Contain Element  xpath=//a[contains(@href, '/tender/bid?id=')]
  Sleep  3
  Click Element                xpath=//a[contains(@href, '/tender/bid?id=')]
  Wait Until Page Contains    Редагування пропозиції    10
  Sleep  2

  Choose File  xpath=//input[@type='file']  ${filepath}
  Sleep  2

  Click Button   xpath=//*[@class='btn btn-success btn-lg w-lg-x3 js-submit-btn']
  Wait Until Page Contains           Пропозиція відредагована  10
  Sleep  1

#  Choose File                 xpath=//input[@type='file']  ${filepath}
#  Sleep  1
#  Click Element               xpath=//form[@id='tender-bid-form']//input[@type='submit']
#  Sleep  1
#  #ubiz.Оновити сторінку з тендером  ${provider}  ${tender_name}

скасувати цінову пропозицію
  [Arguments]  ${username}  ${tender_uaid}  ${bid_response}
  Open Tender

  Page Should Contain Element  xpath=//a[contains(@href, '#bid-delete')]
  Click Element                xpath=//a[contains(@href, '#bid-delete')]
  Sleep  3

  Wait Until Page Contains     Ви впевнені що бажаєте видали свою пропозицію повністю?  10
  Sleep  1

  Click Element                xpath=//button[contains(@class, 'btn btn-default waves-effect waves-light btn-lg')]
  Sleep  1

  Wait Until Page Contains     Пропозиція скасована  10


Оновити сторінку з тендером
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} =  username
  ...      ${ARGUMENTS[1]} =  ${TENDER_UAID}
  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
  Sync Tender
  Open Tender
  #ubiz.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  
Задати питання
  [Arguments]  ${username}  ${tender_uaid}  ${question}

  ${title}=        Get From Dictionary  ${question.data}  title
  ${description}=  Get From Dictionary  ${question.data}  description

  Selenium2Library.Switch Browser    ${username}
  Open Tender
  Switch To Questions
  Sleep  3

  Click Element                      xpath=//a[contains(@href, '/tender/question-create?id=')]
  Wait Until Page Contains           Нове запитання до закупівлі   10
  Sleep  3

  Input text                         id=questionform-title               ${title}
  Input text                         id=questionform-description           ${description}

  Click Button   xpath=//*[@class='btn btn-success btn-lg w-lg-x3 js-submit-btn']
  Sleep  2
  Wait Until Page Contains           Запитання створене.  10

Відповісти на питання
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} = username
  ...      ${ARGUMENTS[1]} = ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} = 0
  ...      ${ARGUMENTS[3]} = answer_data

  ${answer}=     Get From Dictionary  ${ARGUMENTS[3].data}  answer

  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
  #ubiz.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  Open Tender
  Switch To Questions

  Click Element   xpath=//*[@class='panel-heading']//*[contains(@href, '#collapseQuestion')]
  Sleep  1

  Click Element   xpath=//*[contains(@href, '/tender/question-answer?question=')]
  Wait Until Page Contains Element   id=questionanswerform-answer   20

  Input text                         id=questionanswerform-answer               ${answer}
  Click Button   xpath=//*[@class='btn btn-success btn-lg w-lg-x3 js-submit-btn']

  Wait Until Page Contains           Відповідь на питання успішно надана.  10
  Capture Page Screenshot

Внести зміни в тендер
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} =  username
  ...      ${ARGUMENTS[1]} =  ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} =  field_locator (description)
  ...      ${ARGUMENTS[3]} =  text
  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
  #ubiz.Пошук тендера по ідентифікатору  ${ARGUMENTS[0]}  ${ARGUMENTS[1]}
  Wait Until Page Contains  Ідентифікатор закупівлі  20
  Click Element  xpath=//a[contains(@href, '/tender/update?id=')]
  Sleep  1
  Wait Until Page Contains  Редагування закупівлі  10

  Input text    id=tenderbelowthresholdform-description            ${ARGUMENTS[3]}

  Sleep  1
  Click Element   xpath=//*[@id='submitBtn']
  Sleep  1
  Wait Until Page Contains   Закупівля оновлена   10
  Capture Page Screenshot
  Click Element   xpath=//div[contains(@class, 'jconfirm-box')]//button[contains(@class, 'btn btn-default waves-effect waves-light btn-lg')]

додати предмети закупівлі
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} =  username
  ...      ${ARGUMENTS[1]} =  ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} =  3
  ${period_interval}=  Get Broker Property By Username  ${ARGUMENTS[0]}  period_interval
  ${ADDITIONAL_DATA}=  prepare_test_tender_data  ${period_interval}  multi
  ${tender_data}=   Add_data_for_GUI_FrontEnds   ${ADDITIONAL_DATA}
  ${items}=         Get From Dictionary   ${tender_data.data}               items
  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
  Run keyword if   '${TEST NAME}' == 'Можливість додати позицію закупівлі в тендер'   додати позицію
  Run keyword if   '${TEST NAME}' != 'Можливість додати позицію закупівлі в тендер'   видалити позиції

додати позицію
  pzo.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  Sleep  2
  Click Element                     xpath=//a[@class='btn btn-primary ng-scope']
  Sleep  2
  : FOR    ${INDEX}    IN RANGE    1    ${ARGUMENTS[2]} +1
  \   Click Element   xpath=.//*[@id='myform']/tender-form/div/button
  \   Додати предмет   ${items[${INDEX}]}   ${INDEX}
  Sleep  2
  Click Element   xpath=//div[@class='form-actions']/button[./text()='Зберегти зміни']
  Wait Until Page Contains    [ТЕСТУВАННЯ]   10

видалити позиції
  pzo.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  Click Element                     xpath=//a[@class='btn btn-primary ng-scope']
  Sleep  2
  : FOR    ${INDEX}    IN RANGE    1    ${ARGUMENTS[2]} +1
  \   Click Element   xpath=(//button[@class='btn btn-danger ng-scope'])[last()]
  \   Sleep  1
  Sleep  2
  Wait Until Page Contains Element   xpath=//div[@class='form-actions']/button[./text()='Зберегти зміни']   10
  Click Element   xpath=//div[@class='form-actions']/button[./text()='Зберегти зміни']
  Wait Until Page Contains    [ТЕСТУВАННЯ]   10

Отримати інформацію із тендера
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  fieldname
  Switch browser   ${ARGUMENTS[0]}
  Run Keyword If  'question' in '${ARGUMENTS[1]}'  Switch To Questions
  Run Keyword And Return If  'status' in '${ARGUMENTS[1]}'  Отримати інформацію про ${ARGUMENTS[1]}  ${ARGUMENTS[0]}  ${TENDER.TENDER_UAID}
  Run Keyword And Return  Отримати інформацію про ${ARGUMENTS[1]}

Отримати текст із поля і показати на сторінці
  [Arguments]   ${fieldname}
  #sleep  3
#  відмітити на сторінці поле з тендера   ${fieldname}   ${locator.${fieldname}}
  Wait Until Page Contains Element    ${locator.${fieldname}}    22
  #Sleep  1
  ${return_value}=   Get Text  ${locator.${fieldname}}
  [return]  ${return_value}

Отримати інформацію про title
  ${return_value}=   get_text_excluding_children  ${locator.title}
  ${return_value}=   Strip String  ${return_value}
  [return]  ${return_value}

Отримати інформацію про description
  ${return_value}=   Отримати текст із поля і показати на сторінці   description
  [return]  ${return_value}

Отримати інформацію про minimalStep.amount
  ${return_value}=   Отримати текст із поля і показати на сторінці   minimalStep.amount
  ${return_value}=  Evaluate  ''.join('${return_value}'.split()[:-1])
  ${return_value}=   Convert To Number   ${return_value}
  [return]  ${return_value}

Отримати інформацію про value.amount
  ${return_value}=   Отримати текст із поля і показати на сторінці  value.amount
  ${return_value}=  Evaluate  ''.join('${return_value}'.split()[:-3])
  ${return_value}=   Convert To Number   ${return_value}
  [return]  ${return_value}

Отримати інформацію про value.currency
  [return]  UAH
#  ${return_value}=   Отримати текст із поля і показати на сторінці  value.amount
#  ${return_value}=   Evaluate   "".join("${return_value}".split(' ')[:-3])
#  ${return_value}=   Convert To Number   ${return_value}
#  [return]  ${return_value}

Отримати інформацію про value.valueAddedTaxIncluded
  ${return_value}=   Отримати текст із поля і показати на сторінці  value.amount
  ${return_value}=  Run Keyword If  'ПДВ' in '${return_value}'  Set Variable  True
    ...  ELSE Set Variable  False
  Log  ${return_value}
  ${return_value}=   Convert To Boolean   ${return_value}
  [return]  ${return_value}

Відмітити на сторінці поле з тендера
  [Arguments]   ${fieldname}  ${locator}
  ${last_note_id}=  Add pointy note   ${locator}   Found ${fieldname}   width=200  position=bottom
  Align elements horizontally    ${locator}   ${last_note_id}
  sleep  1
  Remove element   ${last_note_id}

Отримати інформацію про tenderId
  ${return_value}=   Отримати текст із поля і показати на сторінці   tenderId
  [return]  ${return_value}

Отримати інформацію про procuringEntity.name
  ${return_value}=   Отримати текст із поля і показати на сторінці   procuringEntity.name
  [return]  ${return_value}

Отримати інформацію про enquiryPeriod.startDate
  ${return_value}=   Отримати текст із поля і показати на сторінці  enquiryPeriod.startDate
  ${return_value}=   Split String  ${return_value}  -
  ${return_value}=   Strip String  ${return_value[0]}
  ${return_value}=   convert_date_for_compare   ${return_value}
  [return]  ${return_value}

Отримати інформацію про enquiryPeriod.endDate
  ${return_value}=   Отримати текст із поля і показати на сторінці  enquiryPeriod.endDate
  ${return_value}=   Split String  ${return_value}  -
  ${return_value}=   Strip String  ${return_value[1]}
  ${return_value}=   convert_date_for_compare   ${return_value}
  [return]  ${return_value}

Отримати інформацію про tenderPeriod.startDate
  ${return_value}=   Отримати текст із поля і показати на сторінці  tenderPeriod.startDate
  ${return_value}=   Split String  ${return_value}  -
  ${return_value}=   Strip String  ${return_value[0]}
  ${return_value}=   convert_date_for_compare   ${return_value}
  [return]  ${return_value}

Отримати інформацію про tenderPeriod.endDate
  ${return_value}=   Отримати текст із поля і показати на сторінці  tenderPeriod.endDate
  ${return_value}=   Split String  ${return_value}  -
  ${return_value}=   Strip String  ${return_value[1]}
  ${return_value}=   convert_date_for_compare   ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[0].description
  Click Element                      xpath=//*[contains(@href, '#collapseItem')]
  Sleep  1
  ${return_value}=   Отримати текст із поля і показати на сторінці   items[0].description
  [return]  ${return_value}

Отримати інформацію про items[0].unit.code
  ${return_value}=   Отримати текст із поля і показати на сторінці   items[0].quantity
  ${return_value}=   Split String  ${return_value}  max_split=1
  Run Keyword And Return If  '${return_value[1]}'== 'кілограми'   Convert To String  KGM
  [return]  ${return_value}

Отримати інформацію про items[0].unit.name
  ${return_value}=   Отримати текст із поля і показати на сторінці   items[0].quantity
  ${return_value}=   Split String  ${return_value}  max_split=1
  [return]  ${return_value[1]}

Отримати інформацію про items[0].quantity
  ${return_value}=   Отримати текст із поля і показати на сторінці   items[0].quantity
  ${return_value}=   Split String  ${return_value}  max_split=1
  ${return_value}=   Convert To Number  ${return_value[0]}
  [return]  ${return_value}

Отримати інформацію про items[0].classification.scheme  
  [return]  CPV
  #${return_value}=   Отримати текст із поля і показати на сторінці  items[0].classification.scheme
  #${return_value}=   Get Substring  ${return_value}  start=0  end=-1
  #${return_value}=   Split String From Right  ${return_value}  max_split=1
  #[return]  ${return_value[1]}

Отримати інформацію про items[0].classification.id
  ${return_value}=   Отримати текст із поля і показати на сторінці  items[0].classification.id
  ${return_value}=   Split String  ${return_value}  max_split=1
  [return]  ${return_value[0]}

Отримати інформацію про items[0].classification.description
  ${return_value}=   Отримати текст із поля і показати на сторінці  items[0].classification.id
  ${return_value}=   Split String  ${return_value}  max_split=1
  [return]  ${return_value[1]}

Отримати інформацію про items[0].additionalClassifications[0].scheme
  [return]  ДКПП
  #${return_value}=   Отримати текст із поля і показати на сторінці  items[0].additionalClassifications[0].scheme
  #${return_value}=   Get Substring  ${return_value}  start=0  end=-1
  #${return_value}=   Split String From Right  ${return_value}  max_split=1
  #[return]  ${return_value[1]}

Отримати інформацію про items[0].additionalClassifications[0].id
  ${return_value}=   Отримати текст із поля і показати на сторінці  items[0].additionalClassifications[0].id
  ${return_value}=   Split String  ${return_value}
  [return]  ${return_value[0]}

Отримати інформацію про items[0].additionalClassifications[0].description
  ${return_value}=  Отримати текст із поля і показати на сторінці  items[0].additionalClassifications[0].id
  ${return_value}=   Split String  ${return_value}  max_split=1
  [return]  ${return_value[1]}

Отримати інформацію про items[0].deliveryAddress.postalCode
  ${return_value}=  Отримати текст із поля і показати на сторінці  items[0].deliveryAddress.postalCode
  [return]  ${return_value}

Отримати інформацію про items[0].deliveryAddress.countryName
  ${return_value}=  Отримати текст із поля і показати на сторінці  items[0].deliveryAddress.countryName
  [return]  ${return_value}

Отримати інформацію про items[0].deliveryAddress.region
  ${return_value}=  Отримати текст із поля і показати на сторінці  items[0].deliveryAddress.region
  [return]  ${return_value}

Отримати інформацію про items[0].deliveryAddress.locality
  ${return_value}=  Отримати текст із поля і показати на сторінці  items[0].deliveryAddress.locality
  [return]  ${return_value}

Отримати інформацію про items[0].deliveryAddress.streetAddress
  ${return_value}=  Отримати текст із поля і показати на сторінці  items[0].deliveryAddress.address
  [return]  ${return_value}

Отримати інформацію про items[0].deliveryDate.endDate
  Click Element                      xpath=//*[contains(@href, '#collapseItem')]
  Sleep  1
  ${return_value}=  Отримати текст із поля і показати на сторінці  items[0].deliveryDate.endDate
#  ${return_value}=   Split String  ${return_value}  max_split=1
#  ${return_value}=   convert_date_for_compare   ${return_value[1]}
  [return]  ${return_value}

Отримати інформацію про items[0].deliveryLocation.latitude
  Fail  Координати не підтримуються майданчиком

Отримати інформацію про items[0].deliveryLocation.longitude
  Fail  Координати не підтримуються майданчиком

Отримати інформацію про questions[0].title
  Run Keyword And Return  get_text_excluding_children  ${locator.questions[0].title}

Отримати інформацію про questions[0].description
  Run Keyword And Return  get_text_excluding_children  ${locator.questions[0].description}

Отримати інформацію про questions[0].date
  ${return_value}=  get_text_excluding_children  ${locator.questions[0].date}
  Run Keyword And Return  convert_date_for_compare  ${return_value}

Отримати інформацію про questions[0].answer
  Run Keyword And Return  get_text_excluding_children  ${locator.questions[0].answer}

Отримати інформацію про status
  [Arguments]  ${username}  ${tenderId}
  Sync Tender
  Open Tender
  ${return_value}=   get_invisible_text  ${locator.status}
  #${time}=  Get Time
  #${str}=  Catenate  ${time}  ${return_value}
  #Log To Console  ${str}
  [return]  ${return_value}

Отримати посилання на аукціон для глядача
  [Arguments]  ${username}  ${tenderId}
  Selenium2Library.Switch browser  ${username}
#  pzo.Оновити сторінку з тендером  ${username}  ${tenderId}
  Open Tender
  ${return_value}=   get_invisible_text  xpath=//*[contains(@class, 'hidden auction-url')]
  [return]  ${return_value}
#  Run Keyword And Return  Отримати посилання на аукціон  ${username}  ${tenderId}

Отримати посилання на аукціон для учасника
  [Arguments]  ${username}  ${tenderId}
  Selenium2Library.Switch browser  ${username}
#  pzo.Оновити сторінку з тендером  ${username}  ${tenderId}
  Open Tender
  ${return_value}=   get_invisible_text  xpath=//*[contains(@class, 'hidden auction-participation-url')]
  [return]  ${return_value}
#  Run Keyword And Return  Отримати посилання на аукціон  ${username}  ${tenderId}

Отримати посилання на аукціон
  [Arguments]  ${username}  ${tenderId}
#  Selenium2Library.Switch browser  ${username}
#  pzo.Оновити сторінку з тендером  ${username}  ${tenderId}
#  Run Keyword And Return  Get Text  xpath=//div[contains(@href, 'https://auction-sandbox.openprocurement.org/tenders/')]
#  Run Keyword And Return  Get Location  xpath=//*[contains(@href, 'https://auction-sandbox.openprocurement.org/tenders/')]


Wait date
  [Arguments]  ${date}
  ${sleep}=  wait_to_date  ${date}
  Run Keyword If  ${sleep} > 0  Sleep  ${sleep}

Switch To Questions
  Click Element                      xpath=//a[contains(@href, '/tender/questions?id=')]
  Wait Until Page Contains           Питання/відповіді   10

Save tender ID
  ${status}=  Run keyword And Return Status  Dictionary Should Not Contain Key  ${TENDER}  TENDER_ID
  Run Keyword If  ${status}  Add id to tender

Add id to tender
  ${url}=   Log Location
# ${tender_id}=  Split String From Right  ${url}  =  max_split=1
  ${tender_id}=  Split String From Right  ${url}  /  max_split=1
  Set To Dictionary  ${TENDER}  TENDER_ID=${tender_id[1]}

Get Tender Sync Url
  [Arguments]  ${tender_id}
  Run Keyword And Return  Catenate  SEPARATOR=  ${tender_sync_prefix}  ${tender_id}  
#${tender_sync_postfix}  

Sync Tender
  ${status}=  Run keyword And Return Status  Dictionary Should Not Contain Key  ${TENDER}  TENDER_ID
  Run Keyword And Return If  ${status}  Go To  ${BROKERS['pzo'].syncpage}
  ${tender_id}=  Get From Dictionary  ${TENDER}  TENDER_ID
  ${sync_url}=  Get Tender Sync Url  ${tender_id}
  Go To  ${sync_url}

Open Tender
  ${no_id}=  Run Keyword And Return Status  Dictionary Should Not Contain Key  ${TENDER}  TENDER_ID
  Return From Keyword If  ${no_id}
  Sync Tender
  ${tender_id}=  Get From Dictionary  ${TENDER}  TENDER_ID
  ${tender_url}=  Catenate  SEPARATOR=  ${tender_page_prefix}  ${tender_id}  
  Go To  ${tender_url}
  Sleep  1
