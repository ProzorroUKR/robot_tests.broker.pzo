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
${pzo_proc_type}=                                              unknown

*** Keywords ***
Підготувати дані для оголошення тендера
  [Arguments]  ${username}  ${tender_data}  ${param3}
  [return]  ${tender_data}

Підготувати клієнт для користувача
  [Arguments]  ${username}
  [Documentation]  Відкрити браузер, створити об’єкт api wrapper, тощо
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
  Set Global Variable  ${PZO_LOGIN_USER}  ${username}
  #Go To  ${USERS.users['${username}'].homepage}

Створити тендер
  [Arguments]  ${user}  ${tender_data}
  ${tender_data}=   procuring_entity_name  ${tender_data}
  ${tender_data_keys}=  Get Dictionary Keys  ${tender_data.data}
  ${items}=         Get From Dictionary   ${tender_data.data}               items
  ${lots}=          Get From Dictionary   ${tender_data.data}               lots
  ${budget}=        Get From Dictionary   ${tender_data.data.value}         amount
  ${budget}=        convert_float_to_string  ${budget}
  ${quantity}=      Get From Dictionary   ${items[0]}                        quantity
  ${quantity}=      Convert To String     ${quantity}
  ${cpv}=           Get From Dictionary   ${items[0].classification}         id
  ${unit}=          Get From Dictionary   ${items[0].unit}                   name
  ${latitude}       Get From Dictionary   ${items[0].deliveryLocation}    latitude
  ${longitude}      Get From Dictionary   ${items[0].deliveryLocation}    longitude
  ${postalCode}    Get From Dictionary   ${items[0].deliveryAddress}     postalCode
  ${streetAddress}    Get From Dictionary   ${items[0].deliveryAddress}     streetAddress
  ${deliveryDate}   Get From Dictionary   ${items[0].deliveryDate}        endDate
  ${procurementMethodType} =  Set Variable If  'procurementMethodType' in ${tender_data_keys}  ${tender_data.data.procurementMethodType}  belowThreshold
  Set To Dictionary  ${USERS.users['${PZO_LOGIN_USER}']}  tender_methodtype=${procurementMethodType}
  Set To Dictionary  ${USERS.users['${PZO_LOGIN_USER}']}  lots=${lots}
  #
  ${title}=         Get From Dictionary   ${tender_data.data}               title
  ${title_ru}=      Get From Dictionary  ${tender_data.data}  title_ru
  ${title_en}=      Get From Dictionary  ${tender_data.data}  title_en
  ${description}=   Get From Dictionary   ${tender_data.data}               description
  ${description_ru}=  Get From Dictionary  ${tender_data.data}  description_ru
  ${description_en}=  Get From Dictionary  ${tender_data.data}  description_en
  #
  ${lots_title}=  Get From Dictionary  ${lots[0]}  title
  ${lots_title_ru}=  Get From Dictionary  ${lots[0]}  title_ru
  ${lots_title_en}=  Get From Dictionary  ${lots[0]}  title_en
  ${lots_description}=   Get From Dictionary   ${lots[0]}         description

  Selenium2Library.Switch Browser    ${user}
  Go To                             ${USERS.users['${user}'].homepage}
  Wait Until Page Contains          Мої закупівлі   10
  Sleep  1

#  Log To Console  ${MODE}

  Run Keyword And Ignore Error  Click Element                     xpath=//*[contains(@href, '/tender/create')]
  Run Keyword And Ignore Error  Click Element                     xpath=//ol[contains(@class, 'breadcrumb')]//*[contains(@href, '/tender/create')]
  Sleep  1
  Wait Until Page Contains          Створення закупівлі  10

  Run Keyword If  '${procurementMethodType}' == 'aboveThresholdEU'  Select From List By Label  xpath=//select[@id='tenderbelowthresholdform-procurement_method_type']  Відкриті торги з публікацією англ.мовою
  Run Keyword If  '${procurementMethodType}' == 'aboveThresholdUA'  Select From List By Label  xpath=//select[@id='tenderbelowthresholdform-procurement_method_type']  Відкриті торги
  Run Keyword If  '${procurementMethodType}' == 'negotiation'  Select From List By Label  xpath=//select[@id='tenderbelowthresholdform-procurement_method_type']  Переговорна процедура закупівлі
  Run Keyword If  '${procurementMethodType}' == 'belowThreshold'  Select From List By Label  xpath=//select[@id='tenderbelowthresholdform-procurement_method_type']  Допорогова закупівля
  Sleep  3 

  ${pzo_proc_type}=  Convert_to_Lowercase  ${procurementMethodType}

  Input text  id=tender${pzo_proc_type}form-title  ${title}
  Run Keyword If  'cause' in ${tender_data_keys}  Select From List By Value  id=tender${pzo_proc_type}form-cause  ${tender_data.data.cause}
  Run Keyword If  'causeDescription' in ${tender_data_keys}  Input text  id=tender${pzo_proc_type}form-cause_description  ${tender_data.data.causeDescription}
  Run Keyword If  '${procurementMethodType}' == 'aboveThresholdEU'  Input text  id=tender${pzo_proc_type}form-title_en  ${title_en}
  Input text  id=tender${pzo_proc_type}form-description  ${description}
  Run Keyword If  '${procurementMethodType}' == 'aboveThresholdEU'  Input text  id=tender${pzo_proc_type}form-description_en  ${description_en}
  Click Element  id=tender${pzo_proc_type}form-value_added_tax_included
  Run Keyword If  '${procurementMethodType}' == 'belowThreshold'  Створити тендер enquiryPeriod.startDate  ${pzo_proc_type}  ${tender_data.data.enquiryPeriod.startDate}
  Run Keyword If  '${procurementMethodType}' == 'belowThreshold'  Створити тендер enquiryPeriod.endDate  ${pzo_proc_type}  ${tender_data.data.enquiryPeriod.endDate}
  Run Keyword If  '${procurementMethodType}' == 'belowThreshold'  Створити тендер tenderPeriod.startDate  ${pzo_proc_type}  ${tender_data.data.tenderPeriod.startDate}
  Run Keyword If  '${procurementMethodType}' != 'negotiation'  Створити тендер tenderPeriod.end_date  ${pzo_proc_type}  ${tender_data.data.tenderPeriod.endDate}
  Select Checkbox  id=tender${pzo_proc_type}form-quick_mode
  Run Keyword If  '${SUITE_NAME}' == 'Tests Files.Complaints'  Select Checkbox  id=tender${pzo_proc_type}form-auction_skip_mode

  Click Element  xpath=//*[contains(@href, '#collapseLots')]
  Sleep  1
  Click Element  xpath=//span[@data-confirm-text='Ви впевнені що бажаєте видалити поточний лот?']
  Click Element  xpath=//div[contains(@class, 'jconfirm-box')]//button[contains(text(), 'Так')]
  ${lots_length}=  Get Length  ${lots}

  : FOR    ${INDEX}    IN RANGE    0    ${lots_length}
  \   Sleep  2
  \   Click Element  xpath=//a[@href='#add-lots']
  \   Sleep  2
  \   Click Element  jquery=div[data-type="lot"].active span[data-confirm-text="Ви впевнені що бажаєте видалити поточний товар/послугу?"]
  \   Click Element  xpath=//div[contains(@class, 'jconfirm-box')]//button[contains(text(), 'Так')]
  \   Sleep  1
  \   Run Keyword If  'features' in ${tender_data_keys}  Додати лот  ${lots[${INDEX}]}  ${INDEX}  ${procurementMethodType}  ${items}  ${tender_data.data.features}
  \   Run Keyword If  'features' not in ${tender_data_keys}  Додати лот Ex2  ${lots[${INDEX}]}  ${INDEX}  ${procurementMethodType}  ${items}

  Run Keyword If  'features' in ${tender_data_keys}  Click Element  xpath=//*[contains(@href, '#collapseFeatures')]
  Sleep  1
  Run Keyword If  'features' in ${tender_data_keys}  Add Features Ex  ${tender_data.data.features}  tenderer  ${procurementMethodType}  div[@id='collapseFeatures']

  Click Element   xpath=//*[@id='submitBtn']
  Sleep  1
  Wait Until Page Contains   Закупівля створена, дочекайтесь опублікування на сайті уповноваженого органу.   10
  Click Element   xpath=//div[contains(@class, 'jconfirm-box')]//button[contains(@class, 'btn btn-default waves-effect waves-light btn-lg')]
  Sleep  1

  Wait For Sync Tender  360

  ${passed}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  360 s  0 s  Wait For UAID
  Run Keyword Unless  ${passed}  Fatal Error  UAID not found in 360 sec  
  ${tender_UAid}=  Get Text  xpath=//*[contains(@class, 'tender-id')]//*[@class='value']

  ${Ids}=   Convert To String   ${tender_UAid}
  Save Tender ID
  Log  ${Ids}
  [return]  ${Ids}

Створити тендер enquiryPeriod.startDate
  [Arguments]  ${pzo_proc_type}  ${date}
  ${date}=  convert_datetime_for_delivery  ${date}
  ${date}=  Convert Date  ${date}  %d.%m.%Y %H:%M
  Input text  id=tender${pzo_proc_type}form-enquiry_period_start_date  ${date}

Створити тендер enquiryPeriod.endDate
  [Arguments]  ${pzo_proc_type}  ${date}
  ${date}=  convert_datetime_for_delivery  ${date}
  ${date}=  Convert Date  ${date}  %d.%m.%Y %H:%M
  Input text  id=tender${pzo_proc_type}form-enquiry_period_end_date  ${date}

Створити тендер tenderPeriod.startDate
  [Arguments]  ${pzo_proc_type}  ${date}
  ${date}=  convert_datetime_for_delivery  ${date}
  ${date}=  Convert Date  ${date}  %d.%m.%Y %H:%M
  Input text  id=tender${pzo_proc_type}form-tender_period_start_date  ${date}

Створити тендер tenderPeriod.end_date
  [Arguments]  ${pzo_proc_type}  ${date}
  ${date}=  convert_datetime_for_delivery  ${date}
  ${date}=  Convert Date  ${date}  %d.%m.%Y %H:%M
  Input text  id=tender${pzo_proc_type}form-tender_period_end_date  ${date}

Додати лот
  [Arguments]  @{arguments}
  [Documentation]
  ...      ${arguments[0]} ==  lot
  ...      ${arguments[1]} ==  index
  ...      ${arguments[2]} ==  procurementMethodType
  ...      ${arguments[3]} ==  items
  ...      ${arguments[4]} ==  features

  Додати лот Ex  ${arguments[0]}  ${arguments[1]}  ${arguments[2]}

  ${pzo_proc_type}=  Convert_to_Lowercase  ${arguments[2]}
  ${pzo_proc_type}=  Set Variable If  '${pzo_proc_type}' == 'belowthreshold'  ${EMPTY}  ${pzo_proc_type}
  ${items_length}=  Get Length  ${arguments[3]}

  : FOR    ${INDEX}    IN RANGE    0    ${items_length}
  \   Run Keyword If  '${arguments[0].id}' == '${arguments[3][${INDEX}].relatedLot}'  Click Element  jquery=div[data-type="lot"].active a[href="#add-items"]
  \   Run Keyword If  '${arguments[0].id}' == '${arguments[3][${INDEX}].relatedLot}'  Sleep  2
  \   Run Keyword If  '${arguments[0].id}' == '${arguments[3][${INDEX}].relatedLot}'  Додати предмет  ${arguments[3][${INDEX}]}  ${INDEX}  ${arguments[2]}  ${arguments[4]}

  Add Features  ${arguments[4]}  lot  ${arguments[0].id}  ${arguments[2]}  div[contains(@class, 'form-group lot${pzo_proc_type}form-features-dynamic-forms-wrapper')]

Додати лот Ex
  [Arguments]  @{arguments}
  [Documentation]
  ...      ${arguments[0]} ==  lot
  ...      ${arguments[1]} ==  index
  ...      ${arguments[2]} ==  procurementMethodType

  ${lot_keys}=  Get Dictionary Keys  ${arguments[0]}
  ${pzo_proc_type}=   Convert_to_Lowercase   ${arguments[2]}
  ${pzo_proc_type}=   Set Variable If  '${pzo_proc_type}' == 'belowthreshold'  ${EMPTY}  ${pzo_proc_type}
  ${budget}=          Get From Dictionary   ${arguments[0].value}   amount
  ${budget}=          convert_float_to_string  ${budget}

  Input text                         xpath=//div[contains(@class, 'active')]//div[contains(@class, 'form-group field-lot${pzo_proc_type}form')]//input[contains(@id, '-title')]  ${arguments[0].title}
  Run Keyword If  '${arguments[2]}' == 'aboveThresholdEU'  Input text  xpath=//div[contains(@class, 'active')]//div[contains(@class, 'form-group field-lot${pzo_proc_type}form')]//input[contains(@id, '-title_en')]  ${arguments[0].title_en}
  Input text                         xpath=//div[contains(@class, 'active')]//div[contains(@class, 'form-group field-lot${pzo_proc_type}form')]//textarea[contains(@id, '-description')]  ${arguments[0].description}
  Run Keyword If  '${arguments[2]}' == 'aboveThresholdEU'  Input text  xpath=//div[contains(@class, 'active')]//div[contains(@class, 'form-group field-lot${pzo_proc_type}form')]//textarea[contains(@id, '-description_en')]  ${arguments[0].description}
  Input text                         xpath=//div[contains(@class, 'active')]//div[contains(@class, 'form-group field-lot${pzo_proc_type}form')]//input[contains(@id, '-value_amount')]  ${budget}
  Run Keyword If  'minimalStep' in ${lot_keys}  Додати лот Ex step_rate  ${pzo_proc_type}  ${arguments[0].minimalStep.amount}

Додати лот Ex step_rate
  [Arguments]  ${pzo_proc_type}  ${step_rate}
  ${step_rate}=  convert_float_to_string  ${step_rate}
  Input text  xpath=//div[contains(@class, 'active')]//div[contains(@class, 'form-group field-lot${pzo_proc_type}form')]//input[contains(@id, '-min_step_amount')]  ${step_rate}

Додати лот Ex2
  [Arguments]  @{arguments}
  [Documentation]
  ...      ${arguments[0]} ==  lot
  ...      ${arguments[1]} ==  index
  ...      ${arguments[2]} ==  procurementMethodType
  ...      ${arguments[3]} ==  items

  Додати лот Ex  ${arguments[0]}  ${arguments[1]}  ${arguments[2]}

  ${pzo_proc_type}=  Convert_to_Lowercase  ${arguments[2]}
  ${pzo_proc_type}=  Set Variable If  '${pzo_proc_type}' == 'belowthreshold'  ${EMPTY}  ${pzo_proc_type}
  ${items_length}=  Get Length  ${arguments[3]}

  : FOR    ${INDEX}    IN RANGE    0    ${items_length}
  \   Run Keyword If  '${arguments[0].id}' == '${arguments[3][${INDEX}].relatedLot}'  Click Element  jquery=div[data-type="lot"].active a[href="#add-items"]
  \   Run Keyword If  '${arguments[0].id}' == '${arguments[3][${INDEX}].relatedLot}'  Sleep  2
  \   Run Keyword If  '${arguments[0].id}' == '${arguments[3][${INDEX}].relatedLot}'  Додати предмет Ex  ${arguments[3][${INDEX}]}  ${INDEX}  ${arguments[2]}  

Додати предмет
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  item
  ...      ${ARGUMENTS[1]} ==  ${index}
  ...      ${ARGUMENTS[2]} ==  ${procurementMethodType}
  ...      ${arguments[3]} ==  features

  ${item_keys}=  Get Dictionary Keys  ${arguments[0]}
  ${pzo_proc_type}=  Convert_to_Lowercase  ${ARGUMENTS[2]}
  ${pzo_proc_type}=  Set Variable If  '${pzo_proc_type}' == 'belowthreshold'  ${EMPTY}  ${pzo_proc_type}
  ${wraper}=  Convert To String  div[contains(@class, 'form-group lot${pzo_proc_type}form-items-dynamic-forms-wrapper')]

  Додати предмет Ex  ${arguments[0]}  ${arguments[1]}  ${arguments[2]}
  Run Keyword If  'id' in ${item_keys}  Add Features  ${arguments[3]}  item  ${arguments[0].id}  ${arguments[2]}  ${wraper}//div[contains(@class, 'item${pzo_proc_type}form-features-dynamic-forms-wrapper')]

Додати предмет Ex
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  item
  ...      ${ARGUMENTS[1]} ==  ${index}
  ...      ${ARGUMENTS[2]} ==  ${procurementMethodType}
  ${item_keys}=  Get Dictionary Keys  ${ARGUMENTS[0]}
  ${description}=   Get From Dictionary   ${ARGUMENTS[0]}              description
  ${cpv_id}=        Get From Dictionary   ${ARGUMENTS[0].classification}              id
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
  ${description_ru}=  Get From Dictionary   ${ARGUMENTS[0]}  description_ru
  ${description_en}=  Get From Dictionary   ${ARGUMENTS[0]}  description_en
  ${delivery_start}=  Get From Dictionary   ${ARGUMENTS[0].deliveryDate}  startDate
  ${delivery_start}=  convert_datetime_for_delivery  ${delivery_start}
  ${delivery_start}=  Convert Date 	${delivery_start} 	%d.%m.%Y %H:%M

  ${pzo_proc_type}=  Convert_to_Lowercase  ${ARGUMENTS[2]}
  ${pzo_proc_type}=  Set Variable If  '${pzo_proc_type}' == 'belowthreshold'  ${EMPTY}  ${pzo_proc_type}
  ${wraper}=  Convert To String  div[contains(@class, 'form-group lot${pzo_proc_type}form-items-dynamic-forms-wrapper')]

  Input text                         xpath=//div[contains(@class, 'active')]//${wraper}//div[contains(@class, 'active')]//div[contains(@class, 'form-group field-item${pzo_proc_type}form')]//input[contains(@id, '-description')]  ${description}
  Run Keyword If  '${ARGUMENTS[2]}' == 'aboveThresholdEU'  Input text  xpath=//div[contains(@class, 'active')]//${wraper}//div[contains(@class, 'active')]//div[contains(@class, 'form-group field-item${pzo_proc_type}form')]//input[contains(@id, '-description_en')]  ${description_en}
  Input text                         xpath=//div[contains(@class, 'active')]//${wraper}//div[contains(@class, 'active')]//div[contains(@class, 'form-group field-item${pzo_proc_type}form')]//input[contains(@id, '-quantity')]  ${quantity}
  Select From List By Label          xpath=//div[contains(@class, 'active')]//${wraper}//div[contains(@class, 'active')]//div[contains(@class, 'form-group field-item${pzo_proc_type}form')]//select[contains(@id, '-unit_id')]  ${unit}
  
  Click Element                      xpath=//div[contains(@class, 'active')]//${wraper}//div[contains(@class, 'active')]//a[contains(@href, '#classification')]
  Wait Until Element Is Visible      xpath=//div[contains(@id, 'classification-modal')]//h4[contains(@id, 'classificationModalLabel')]
  Sleep  1
  Input text                         xpath=//div[contains(@id, 'classification-modal')]//input[@class='form-control js-input']  ${cpv_id}
  Press key                          xpath=//div[contains(@id, 'classification-modal')]//input[@class='form-control js-input']  \\13
  Sleep  1
  Wait Until Page Contains Element   xpath=//div[contains(@id, 'classification-modal')]//strong[contains(., '${cpv_id}')]  20
  Click Element                      xpath=//div[contains(@id, 'classification-modal')]//i[@class='jstree-icon jstree-checkbox']
  Click Element                      xpath=//div[contains(@id, 'classification-modal')]//button[contains(@class, 'btn btn-default waves-effect waves-light js-submit')]
  Sleep  1
  
  Run Keyword If  'additionalClassifications' in ${item_keys}  Input Additional Classifications  ${ARGUMENTS[0].additionalClassifications}  ${wraper}

  Run Keyword If  '${ARGUMENTS[2]}' == 'belowThreshold'  Click Element  xpath=//div[contains(@class, 'active')]//${wraper}//div[contains(@class, 'active')]//input[contains(@id, '-delivery')]

  Select From List By Label          //div[contains(@class, 'active')]//${wraper}//div[contains(@class, 'active')]//div[contains(@class, 'form-group field-item${pzo_proc_type}form')]//select[contains(@id, '-delivery_region_id')]  ${region}
  Sleep  1
  Input Text                        xpath=//div[contains(@class, 'active')]//${wraper}//div[contains(@class, 'active')]//div[contains(@class, 'form-group field-item${pzo_proc_type}form')]//input[contains(@id, '-delivery_locality')]  ${locality}
  Input Text                        xpath=//div[contains(@class, 'active')]//${wraper}//div[contains(@class, 'active')]//div[contains(@class, 'form-group field-item${pzo_proc_type}form')]//input[contains(@id, '-delivery_street_address')]  ${street}
  Input Text                        xpath=//div[contains(@class, 'active')]//${wraper}//div[contains(@class, 'active')]//div[contains(@class, 'form-group field-item${pzo_proc_type}form')]//input[contains(@id, '-delivery_postal_code')]  ${code}
  Input Text                        xpath=//div[contains(@class, 'active')]//${wraper}//div[contains(@class, 'active')]//div[contains(@class, 'form-group field-item${pzo_proc_type}form')]//input[contains(@id, '-delivery_start_date')]  ${delivery_start}
  Input Text                        xpath=//div[contains(@class, 'active')]//${wraper}//div[contains(@class, 'active')]//div[contains(@class, 'form-group field-item${pzo_proc_type}form')]//input[contains(@id, '-delivery_end_date')]  ${delivery_end}

Input Additional Classifications
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  additionalClassifications
  ...      ${ARGUMENTS[1]} ==  wraper
  Click Element  xpath=//div[contains(@class, 'active')]//${ARGUMENTS[1]}//div[contains(@class, 'active')]//a[contains(@href, '#additionalclassification')]
  Wait Until Element Is Visible  xpath=//div[contains(@id, 'additional-classification-modal')]//h4[contains(@id, 'additionalClassificationModalLabel')]
  Sleep  1

  ${count}=  Get Length  ${ARGUMENTS[0]}
  : FOR    ${INDEX}    IN RANGE    0    ${count}
  \   Click Element  jquery=#additional-classification-modal .nav a[data-toggle="tab"][data-scheme="${ARGUMENTS[0][${INDEX}].scheme}"]
  \   Wait Until Element Is Visible  jquery=#additional-classification-modal .tab-pane.tree-wrapper.active input.js-input
  \   Input text     jquery=#additional-classification-modal .tab-pane.tree-wrapper.active input.js-input  ${ARGUMENTS[0][${INDEX}].id}
  \   Press key      jquery=#additional-classification-modal .tab-pane.tree-wrapper.active input.js-input  \\13
  \   Sleep  2
  \   Wait Until Page Contains Element   jquery=#additional-classification-modal .tab-pane.tree-wrapper.active .tree.js-search-tree strong:contains("${ARGUMENTS[0][${INDEX}].id}")  20
  \   Click Element  jquery=#additional-classification-modal .tab-pane.tree-wrapper.active .tree.js-search-tree li:first i.jstree-checkbox

  Click Element  xpath=//div[contains(@id, 'additional-classification-modal')]//button[contains(@class, 'js-submit')]

Add Features
  [Arguments]  @{arguments}
  [Documentation]
  ...      ${arguments[0]} ==  features
  ...      ${arguments[1]} ==  featureOf
  ...      ${arguments[2]} ==  relatedItemId
  ...      ${arguments[3]} ==  procurementMethodType
  ...      ${arguments[4]} ==  wraper

  ${features_length}=  Get Length  ${arguments[0]}

  : FOR    ${INDEX}    IN RANGE    0    ${features_length}
  \   Run Keyword If  '${arguments[0][${INDEX}].featureOf}' == '${arguments[1]}'  Run Keyword If  '${arguments[2]}' == '${arguments[0][${INDEX}].relatedItem}'  Add Feature  ${arguments[0][${INDEX}]}  ${INDEX}  ${arguments[3]}  ${arguments[4]}  ${arguments[1]}

Add Features Ex
  [Arguments]  @{arguments}
  [Documentation]
  ...      ${arguments[0]} ==  features
  ...      ${arguments[1]} ==  featureOf
  ...      ${arguments[2]} ==  procurementMethodType
  ...      ${arguments[3]} ==  wraper

  ${features_length}=  Get Length  ${arguments[0]}

  : FOR    ${INDEX}    IN RANGE    0    ${features_length}
  \   Run Keyword If  '${arguments[0][${INDEX}].featureOf}' == '${arguments[1]}'  Add Feature  ${arguments[0][${INDEX}]}  ${INDEX}  ${arguments[2]}  ${arguments[3]}  ${arguments[1]}

Add Feature
  [Arguments]  @{arguments}
  [Documentation]
  ...      ${arguments[0]} ==  feature
  ...      ${arguments[1]} ==  index
  ...      ${arguments[2]} ==  procurementMethodType
  ...      ${arguments[3]} ==  wraper  
  ...      ${arguments[4]} ==  featureOf

  Click Element  xpath=//${arguments[3]}//a[@href='#add-features']
  Sleep  2
  Click Element  xpath=//${arguments[3]}//div[contains(@class, 'active')]//span[@data-confirm-text='Ви впевнені що бажаєте видалити поточну опцію?']
  Sleep  1
  Click Element  xpath=//div[contains(@class, 'jconfirm-box')]//button[contains(text(), 'Так')]
  Sleep  1
  Add Feature Ex  ${arguments[0]}  ${arguments[1]}  ${arguments[2]}  ${arguments[3]}  ${arguments[4]}

Add Feature Ex
  [Arguments]  @{arguments}
  [Documentation]
  ...      ${arguments[0]} ==  feature
  ...      ${arguments[1]} ==  index
  ...      ${arguments[2]} ==  procurementMethodType
  ...      ${arguments[3]} ==  wraper
  ...      ${arguments[4]} ==  featureOf

  ${featureOf}=  Set Variable If  '${arguments[4]}' == 'tenderer'  ${EMPTY}  ${arguments[4]}
  ${pzo_proc_type}=  Convert_to_Lowercase  ${arguments[2]}
  ${pzo_proc_type}=  Set Variable If  '${pzo_proc_type}' == 'belowthreshold'  ${EMPTY}  ${pzo_proc_type}
  ${pzo_proc_type}=  Set Variable If  '${pzo_proc_type}' == 'abovethresholdua'  ${EMPTY}  ${pzo_proc_type}
  ${wraper}=  Set Variable If  '${pzo_proc_type}' == ''  form-group field-${featureOf}featureform  form-group field-feature${pzo_proc_type}form
  ${wraper2}=  Set Variable If  '${pzo_proc_type}' == ''  form-group ${featureOf}featureform-enums-dynamic-forms-wrapper  form-group feature${pzo_proc_type}form-enums-dynamic-forms-wrapper
  ${options}=  Get From Dictionary  ${arguments[0]}  enum

  Input text                         xpath=//${arguments[3]}//div[contains(@class, 'active')]//div[contains(@class, '${wraper}')]//input[contains(@id, '-title')]  ${arguments[0].title}
  Run Keyword If  '${arguments[2]}' == 'aboveThresholdEU'  Input text  xpath=//${arguments[3]}//div[contains(@class, 'active')]//div[contains(@class, '${wraper}')]//input[contains(@id, '-title_en')]  ${arguments[0].title_en}
  Input text                         xpath=//${arguments[3]}//div[contains(@class, 'active')]//div[contains(@class, '${wraper}')]//input[contains(@id, '-description')]  ${arguments[0].description}
  Run Keyword If  '${arguments[2]}' == 'aboveThresholdEU'  Input text  xpath=//${arguments[3]}//div[contains(@class, 'active')]//div[contains(@class, '${wraper}')]//input[contains(@id, '-description_en')]  ${arguments[0].description}

  ${options_length}=  Get Length  ${options}

  : FOR    ${INDEX}    IN RANGE    0    ${options_length}
  \   Click Element  xpath=//${arguments[3]}//div[contains(@class, 'active')]//a[@href='#add-enums']
  \   Sleep  2
  \   Input text  xpath=//${arguments[3]}//div[contains(@class, 'active')]//div[contains(@class, '${wraper2}')]//div[contains(@class, 'active')]//input[contains(@id, '-title')]  ${options[${INDEX}].title}
  \   Run Keyword If  '${arguments[2]}' == 'aboveThresholdEU'  Input text  xpath=//${arguments[3]}//div[contains(@class, 'active')]//div[contains(@class, '${wraper2}')]//div[contains(@class, 'active')]//input[contains(@id, '-title_en')]  ${options[${INDEX}].title}
  \   ${value}=  convert_float_to_string  ${options[${INDEX}].value}
  \   ${value}=  Convert To Number  ${value}
  \   ${value}=  multiply_hundred  ${value}
  \   ${value}=  convert_float_to_string  ${value}
  \   Input text  xpath=//${arguments[3]}//div[contains(@class, 'active')]//div[contains(@class, '${wraper2}')]//div[contains(@class, 'active')]//input[contains(@id, '-value')]  ${value}

Wait For UAID
  Sleep  5
  Reload Page
  ${tender_UAid}=  Get Text  xpath=//*[contains(@class, 'tender-id')]//*[@class='value']

Клацнути і дочекатися
  [Arguments]  ${click_locator}  ${wanted_locator}  ${timeout}
  [Documentation]
  ...      click_locator: Where to click
  ...      wanted_locator: What are we waiting for
  ...      timeout: Timeout
  Click Element  ${click_locator}
  Sleep  3
  Wait Until Page Contains Element  ${wanted_locator}  ${timeout}

Шукати і знайти
  Клацнути і дочекатися  xpath=//button[contains(text(), 'Пошук')]  xpath=(//div[@id='tender-list'])//a[contains(@href, '/tender/')][1]  5

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

  Go To  http://dev.pzo.com.ua/utils/tender-sync?tenderid=${ARGUMENTS[1]}
#  Sleep  10

  Load And Wait Text  ${BROKERS['pzo'].homepage}  Публічні закупівлі  4

  Wait Until Page Contains Element    id=tendersearchform-query    20
  Input Text    id=tendersearchform-query    ${ARGUMENTS[1]}

  ${timeout_on_wait}=  Get Broker Property By Username  ${ARGUMENTS[0]}  timeout_on_wait

#  ${passed}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  ${timeout_on_wait} s  0 s  Шукати і знайти
#  Run Keyword Unless  ${passed}  Fatal Error  Тендер не знайдено за ${timeout_on_wait} секунд
  ${passed}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  360 s  0 s  Шукати і знайти
  Run Keyword Unless  ${passed}  Fatal Error  Тендер не знайдено за 360 секунд

#  Sleep  3
  Wait Until Page Contains Element    xpath=(//div[@id='tender-list'])//a[contains(@href, '/tender/')][1]    20
  Sleep  2
  Click Element    xpath=(//div[@id='tender-list'])//a[contains(@href, '/tender/')][1]
  Wait Until Page Contains    ${ARGUMENTS[1]}   60
  Save Tender ID
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
  Sleep  2

  Save Tender  

Wait For Sync Tender
  [Arguments]  ${timeout}
  ${passed}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  ${timeout} s  0 s  Wait For Sync Tender Finish
  Run Keyword Unless  ${passed}  Fatal Error  Sync Finish not finish in ${timeout} sec

Wait For Sync Tender Finish
  Sleep  5
  Reload Page
  Page Should Not Contain  Синхронізація з ЦБД  

Створити постачальника, додати документацію і підтвердити його
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  ${username}
  ...      ${ARGUMENTS[1]} ==  ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} ==  ${award_data}
  ...      ${ARGUMENTS[3]} ==  ${filepath}
  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
  Open Tender
  Wait Until Page Contains  Ідентифікатор закупівлі  20
  Click Element  xpath=//a[contains(@href, '/tender/update?id=')]
  Sleep  1
  Wait Until Page Contains  Редагування закупівлі  10

  Click Element   xpath=//*[@class='panel-heading']//*[@href='#collapseAward']
  Sleep  1

  Click Element  jquery=div.awards-dynamic-forms-wrapper .nav a.js-dynamic-form-add
  Sleep  2
  Додати постачальника  ${ARGUMENTS[2].data.lotID}  ${ARGUMENTS[2].data}

  Save Tender

  Click Element   jquery=#tender-part-pjax .list-group-item[href*="tender/qualification"]
  Sleep  1
  Wait Until Page Contains  Кваліфікація  10  
  Select From List By Value  id=qualificationform-decision  accept
  Choose File  jquery=div.documents-dynamic-forms-wrapper div[data-type="awarddocument"].active div.fileupload-input-wrapper input[type="file"]  ${ARGUMENTS[3]}
  Sleep  2
  Wait Until Page Contains Element  jquery=div.documents-dynamic-forms-wrapper div[data-type="awarddocument"].active div.fileupload-input-wrapper div.btn.item  60
  Click Element   id=qualificationform-qualified
  
  Click Element   jquery=#tender-qualification-form .js-submit-btn
  Sleep  1
  Wait Until Page Contains   Рішення завантажене, тепер потрібно накласти ЕЦП.   60
  Click Element   xpath=//div[contains(@class, 'jconfirm-box')]//button[contains(@class, 'btn btn-default waves-effect waves-light btn-lg')]
  Sleep  1

  Click Element   jquery=#tender-qualification-form .js-submit-btn
  Sleep  1
  Load Sign  
  Wait Until Page Contains   ЕЦП успішно накладено на рішення, тепер потрібно підтвердити рішення.   10
  Click Element   xpath=//div[contains(@class, 'jconfirm-box')]//button[contains(@class, 'btn btn-default waves-effect waves-light btn-lg')]
  Sleep  1

  Click Element   jquery=#tender-qualification-form .js-submit-btn
  Sleep  1
  Wait Until Page Contains   Рішення підтверджене, очікує опублікування на сайті уповноваженого органу.   10
  Click Element   xpath=//div[contains(@class, 'jconfirm-box')]//button[contains(@class, 'btn btn-default waves-effect waves-light btn-lg')]
  Sleep  1

  Wait For Sync Tender  360

Додати постачальника
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} =  ${lot_id}
  ...      ${ARGUMENTS[1]} =  ${award_data}
  ${lots_length}=  Get Length  ${USERS.users['${PZO_LOGIN_USER}'].lots}
  : FOR    ${INDEX}    IN RANGE    0    ${lots_length}
  \   Run Keyword If  '${USERS.users['${PZO_LOGIN_USER}'].lots[${INDEX}].id}' == '${ARGUMENTS[0]}'  Select From List By Label    jquery=div.awards-dynamic-forms-wrapper div.dynamic-forms-list div[data-type="award"].active select[id$="-award_lot_key"]     ${USERS.users['${PZO_LOGIN_USER}'].lots[${INDEX}].title}
  Input Text    jquery=div.awards-dynamic-forms-wrapper div.dynamic-forms-list div[data-type="award"].active input[id$="-award_organization_name"]    ${ARGUMENTS[1].suppliers[0].identifier.legalName}
  Input Text    jquery=div.awards-dynamic-forms-wrapper div.dynamic-forms-list div[data-type="award"].active input[id$="-award_organization_edrpou"]    ${ARGUMENTS[1].suppliers[0].identifier.id}
  Select From List By Label    jquery=div.awards-dynamic-forms-wrapper div.dynamic-forms-list div[data-type="award"].active select[id$="-award_organization_region_id"]    ${ARGUMENTS[1].suppliers[0].address.region}
  Input Text    jquery=div.awards-dynamic-forms-wrapper div.dynamic-forms-list div[data-type="award"].active input[id$="-award_organization_postal_code"]    ${ARGUMENTS[1].suppliers[0].address.postalCode}
  Input Text    jquery=div.awards-dynamic-forms-wrapper div.dynamic-forms-list div[data-type="award"].active input[id$="-award_organization_locality"]    ${ARGUMENTS[1].suppliers[0].address.locality}
  Input Text    jquery=div.awards-dynamic-forms-wrapper div.dynamic-forms-list div[data-type="award"].active input[id$="-award_organization_street_address"]    ${ARGUMENTS[1].suppliers[0].address.streetAddress}
  Input Text    jquery=div.awards-dynamic-forms-wrapper div.dynamic-forms-list div[data-type="award"].active input[id$="-award_organization_contact_point_name"]    ${ARGUMENTS[1].suppliers[0].contactPoint.name}
  Input Text    jquery=div.awards-dynamic-forms-wrapper div.dynamic-forms-list div[data-type="award"].active input[id$="-award_organization_contact_point_email"]    ${ARGUMENTS[1].suppliers[0].contactPoint.email}
  Input Text    jquery=div.awards-dynamic-forms-wrapper div.dynamic-forms-list div[data-type="award"].active input[id$="-award_organization_contact_point_phone"]    ${ARGUMENTS[1].suppliers[0].contactPoint.telephone}
  Input Text    jquery=div.awards-dynamic-forms-wrapper div.dynamic-forms-list div[data-type="award"].active input[id$="-award_value_amount"]    ${ARGUMENTS[1].value.amount}  

Підтвердити підписання контракту
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} =  ${username}
  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
  Open Tender
  Wait Until Page Contains  Ідентифікатор закупівлі  20
  Click Element  xpath=//a[contains(@href, '/tender/contract?id=')]
  Sleep  1
  Wait Until Page Contains  Завантаження контракту  10
  Sleep  61
  Перевірити неможливість підписання контракту
  Input Text    id=contractform-contract_number  1234567890
  ${date_start}=  Get Current Date  increment=02:00:00  result_format=%d.%m.%Y %H:%M
  Input Text    id=contractform-date_start  ${date_start}
  ${date_end}=  Get Current Date  increment=04:00:00  result_format=%d.%m.%Y %H:%M
  Input Text    id=contractform-date_end  ${date_end}
  ${file_path_t}  ${file_name_t}  ${file_content_t}=  create_fake_doc
  Choose File   jquery=#tender-contract-form .documents-dynamic-forms-wrapper .item-wrapper.active[data-type="contractdocument"] input[type=file]  ${file_path_t}
  Wait Until Page Contains  ${file_name_t}  20

  Click Element   jquery=#tender-contract-form .js-submit-btn
  Sleep  1
  Wait Until Page Contains   Контракт успішно завантажений   10
  Click Element   xpath=//div[contains(@class, 'jconfirm-box')]//button[contains(@class, 'btn btn-default waves-effect waves-light btn-lg')]
  Sleep  1

  Wait Until Page Contains   Активувати контракт   10
  Click Element  xpath=//a[contains(@href, '/tender/contract-activate?id=')]
  Sleep  1
  Wait Until Page Contains  Активація контракту  10
  Click Element   jquery=#tender-contract-form .js-submit-btn
  Sleep  1
  Load Sign  
  Wait Until Page Contains   ЕЦП успішно накладено   10
  Click Element   xpath=//div[contains(@class, 'jconfirm-box')]//button[contains(@class, 'btn btn-default waves-effect waves-light btn-lg')]
  Sleep  1

  Click Element   jquery=#tender-contract-form .js-submit-btn
  Sleep  1
  Wait Until Page Contains   Контракт успішно активовано   10
  Click Element   xpath=//div[contains(@class, 'jconfirm-box')]//button[contains(@class, 'btn btn-default waves-effect waves-light btn-lg')]
  Sleep  10
  
Перевірити неможливість підписання контракту
  ${date_sign}=  Get Current Date  local  0  %d.%m.%Y %H:%M  
  Input Text    id=contractform-date_signed  '${date_sign}'
  Execute JavaScript    $('#contractform-date_signed').blur();
  Sleep  3
  Capture Page Screenshot
  ${status}=  Run keyword And Return Status  Page Should Contain  Значення "Дата підписання" повинно бути більшим значення
  Run Keyword If  ${status}  Fail  Підписати контракт неможливо
  ${status}=  Run keyword And Return Status  Page Should Contain  Контракт можна буде підписати після
  Run Keyword If  ${status}  Fail  Підписати контракт неможливо

Load Sign
  ${status}=  Run keyword And Return Status  Wait Until Page Contains   Горобець Сергій Миколайович   20
  Run Keyword If  ${status} == False  Load Sign Data
  Click Element   id=SignDataButton
  Sleep  1    

Load Sign Data
  Wait Until Page Contains   Оберіть ЦСК:   10
  Wait Until Page Contains Element   id=CAsServersSelect   20
  Sleep  15
  ${status_info}=  get_text  xpath=//div[@id='PKStatusInfo']
  @{status_info_split}=  Split String  ${status_info}
  ${status_info_check}=  Set Variable If  '@{status_info_split}[0]' != 'Оберіть'  1  0
  Run Keyword If  '${status_info_check}' == '0'  Select From List By Label   id=CAsServersSelect     Тестовий ЦСК АТ "ІІТ"
  Run Keyword If  '${status_info_check}' == '0'  Wait Until Page Contains Element  id=PKeyFileInput  20
  Run Keyword If  '${status_info_check}' == '0'  Sleep  2
  Run Keyword If  '${status_info_check}' == '0'  Choose File   id=PKeyFileInput     ${CURDIR}/Key-6.dat
  Run Keyword If  '${status_info_check}' == '0'  Sleep  2
  Run Keyword If  '${status_info_check}' == '0'  Wait Until Page Contains Element  id=PKeyPassword  20
  Run Keyword If  '${status_info_check}' == '0'  Input Text    id=PKeyPassword     qwerty
  Run Keyword If  '${status_info_check}' == '0'  Wait Until Page Contains Element  id=PKeyReadButton  20
  Run Keyword If  '${status_info_check}' == '0'  Click Element   id=PKeyReadButton
  Run Keyword If  '${status_info_check}' == '0'  Sleep  1
  Run Keyword If  '${status_info_check}' == '0'  Wait Until Page Contains   Горобець Сергій Миколайович   20
  Run Keyword If  '${status_info_check}' == '0'  Sleep  2
  Wait Until Page Contains Element  id=SignDataButton  20
  Click Element   id=SignDataButton
  Sleep  1  

Wait user action
  [Arguments]  @{ARGUMENTS}
  Execute JavaScript    alertMsg({content: 'wait user action', autoClose: '299'});
  Wait Until Page Does Not Contain    wait user action  300

Оновити сторінку з тендером
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} =  username
  ...      ${ARGUMENTS[1]} =  ${TENDER_UAID}
  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
  Sync Tender
  Open Tender

Внести зміни в тендер
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} =  username
  ...      ${ARGUMENTS[1]} =  ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} =  field_locator (description)
  ...      ${ARGUMENTS[3]} =  text
  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}

  Open Tender

  ${procurementMethodType}=  Отримати інформацію із тендера procurementMethodType
  ${pzo_proc_type}=  Convert_to_Lowercase  ${procurementMethodType}

#  Log To Console  ${ARGUMENTS[0]}
#  Log To Console  ${ARGUMENTS[1]}
#  Log To Console  ${ARGUMENTS[2]}
#  Log To Console  ${ARGUMENTS[3]}

  Click Element  xpath=//a[contains(@href, '/tender/update?id=')]
  Sleep  1
  Wait Until Page Contains  Редагування закупівлі  10

  Run Keyword If  '${ARGUMENTS[2]}' == 'tenderPeriod.endDate'  Внести зміни в тендер tenderPeriod.endDate  ${ARGUMENTS[3]}  ${procurementMethodType}
  Run Keyword If  '${ARGUMENTS[2]}' == 'description'  Input text  id=tender${pzo_proc_type}form-description  ${ARGUMENTS[3]}
  Sleep  1

  Save Tender
  Capture Page Screenshot

Внести зміни в тендер tenderPeriod.endDate
  [Arguments]  ${value}  ${procurementMethodType}
  ${pzo_proc_type}=  Convert_to_Lowercase  ${procurementMethodType}
  ${converted_date}=  convert_datetime_for_delivery  ${value}
  ${converted_date}=  Convert Date  ${converted_date}  %d.%m.%Y %H:%M
  Input text  id=tender${pzo_proc_type}form-tender_period_end_date  ${converted_date}

Отримати посилання на аукціон для глядача
  [Arguments]  ${username}  ${tenderId}
  Selenium2Library.Switch browser  ${username}
  Wait For Status  active.auction  ${username}  100000
  Open Tender
  ${return_value}=   get_invisible_text  xpath=//*[contains(@class, 'hidden auction-url')]
  [return]  ${return_value}

Отримати посилання на аукціон для учасника
  [Arguments]  ${username}  ${tenderId}
  Selenium2Library.Switch browser  ${username}
  Wait For Status  active.auction  ${username}  100000
  ${passed}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  100000 s  0 s  Search Participation Url
  Run Keyword Unless  ${passed}  Fatal Error  Link не знайдено за 100000 секунд
  ${return_value}=   get_invisible_text  xpath=//*[contains(@class, 'hidden auction-participation-url')]
  [return]  ${return_value}

Wait date
  [Arguments]  ${date}
  ${sleep}=  wait_to_date  ${date}
  Run Keyword If  ${sleep} > 0  Sleep  ${sleep}

Switch To Questions
  Click Element                      xpath=//a[contains(@href, '/tender/questions?id=')]
  Wait Until Page Contains           Питання/відповіді   10

Save tender ID
  ${status}=  Run keyword And Return Status  Dictionary Should Not Contain Key  ${USERS.users['${PZO_LOGIN_USER}']}  TENDER_ID
  Run Keyword If  ${status}  Add id to tender

Add id to tender
  ${url}=   Log Location
  ${tender_id}=  Split String From Right  ${url}  /  max_split=1
  Set To Dictionary  ${USERS.users['${PZO_LOGIN_USER}']}  TENDER_ID=${tender_id[1]}

Get Tender Sync Url
  [Arguments]  ${tender_id}
  Run Keyword And Return  Catenate  SEPARATOR=  ${tender_sync_prefix}  ${tender_id}  

Sync Tender
  ${status}=  Run keyword And Return Status  Dictionary Should Not Contain Key  ${USERS.users['${PZO_LOGIN_USER}']}  TENDER_ID
  Run Keyword And Return If  ${status}  Go To  ${BROKERS['pzo'].syncpage}
  ${tender_id}=  Get From Dictionary  ${USERS.users['${PZO_LOGIN_USER}']}  TENDER_ID
  ${sync_url}=  Get Tender Sync Url  ${tender_id}
  Go To  ${sync_url}

Open Tender
  ${no_id}=  Run Keyword And Return Status  Dictionary Should Not Contain Key  ${USERS.users['${PZO_LOGIN_USER}']}  TENDER_ID
  Return From Keyword If  ${no_id}
  Wait For All Transfer Complete
  Sync Tender
  ${tender_id}=  Get From Dictionary  ${USERS.users['${PZO_LOGIN_USER}']}  TENDER_ID
  ${tender_url}=  Catenate  SEPARATOR=  ${tender_page_prefix}  ${tender_id}  
  Go To  ${tender_url}
  Sleep  1

Wait For All Transfer Complete
  ${sync_passed}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  100 s  0 s  Wait For Transfer Complete
  Run Keyword Unless  ${sync_passed}  Fatal Error  Sync not finish in 100 sec

Wait For Transfer Complete
  Sleep  3
  Reload Page
  Run Keyword And Ignore Error  Click Element  xpath=//div[@id='myBid']//a[contains(@href,'#collapseMyBid')]
  Sleep  1
  Page Should Not Contain Element  xpath=//i[@class='fa fa-spin fa-refresh']

Звірити статус тендераa
  [Arguments]  ${username}  ${left}
  ${right}=  Отримати інформацію із тендера status
#  Log To Console  ${left}
#  Log To Console  ${right}
  Порівняти об'єкти  ${left}  ${right}

Check Status
  [Arguments]  ${wanted_status}  ${username}
  Sleep  5
  Open Tender  
  Звірити статус тендераa  ${username}  ${wanted_status}

Wait For Status
  [Arguments]  ${wanted_status}  ${username}  ${timeout}
  ${passed}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  ${timeout} s  0 s  Check Status  ${wanted_status}  ${username}
  Run Keyword Unless  ${passed}  Fatal Error  Status ${wanted_status} не знайдено за ${timeout} секунд

Search Participation Url
  Sleep  30
  Open Tender
  ${return_value}=   get_invisible_text  xpath=//*[contains(@class, 'hidden auction-participation-url')]

Start Edit Lot
  [Arguments]  ${lot_id}
  Open Tender
  Click Element  xpath=//a[contains(@href, '/tender/update?id=')]
  Wait Until Page Contains  Основна інформація  10
  Click Element  xpath=//*[contains(@href, '#collapseLots')]
  Sleep  1
  Click Element  xpath=//div[@id='collapseLots']//span[contains(text(), '${lot_id}')] 
  Sleep  1

Save Tender
  Sleep  1
  Click Button  xpath=//*[text()='Зберегти зміни']
  Wait Until Page Contains  Закупівля оновлена  10
  Sleep  1
  Click Element   xpath=//div[contains(@class, 'jconfirm-box')]//button[contains(@class, 'btn btn-default waves-effect waves-light btn-lg')]
  Sleep  1
  Wait For Sync Tender  360

Завантажити документ в лот
  [Arguments]  ${username}  ${file_path}  ${tender_uaid}  ${lot_id}
  Switch browser   ${username}

  ${procurementMethodType}=  Get From Dictionary  ${USERS.users['${PZO_LOGIN_USER}']}  tender_methodtype
  ${pzo_proc_type}=  Convert_to_Lowercase  ${procurementMethodType}

  Start Edit Lot  ${lot_id}

  Click Element  xpath=//div[@id='collapseLots']//div[contains(@class, 'form-group lot${pzo_proc_type}form-documents-dynamic-forms-wrapper')]//a[@href='#add-documents']
  Sleep  1

  Wait Until Page Contains Element  xpath=//div[@id='collapseLots']//div[contains(@class, 'form-group lot${pzo_proc_type}form-documents-dynamic-forms-wrapper')]//input[@type='file']  10
  Choose File  xpath=//div[@id='collapseLots']//div[contains(@class, 'form-group lot${pzo_proc_type}form-documents-dynamic-forms-wrapper')]//input[@type='file']  ${filepath}
  Sleep  2

  Save Tender

Змінити лот 
  [Arguments]  ${username}  ${tender_uaid}  ${lot_id}  ${field}  ${value}
  Switch browser   ${username}

  ${procurementMethodType}=  Get From Dictionary  ${USERS.users['${PZO_LOGIN_USER}']}  tender_methodtype
  ${pzo_proc_type}=  Convert_to_Lowercase  ${procurementMethodType}

  Start Edit Lot  ${lot_id}

  Run Keyword If  '${field}' == 'value.amount'  Змінити лот value.amount  ${value}  ${pzo_proc_type}
  Run Keyword If  '${field}' == 'minimalStep.amount'  Змінити лот minimalStep.amount  ${value}  ${pzo_proc_type}
  Run Keyword If  '${field}' == 'description'  Input text  xpath=//div[contains(@class, 'form-group tender${pzo_proc_type}form-lots-dynamic-forms-wrapper')]//div[contains(@class, 'active')]//div[contains(@class, 'form-group field-lot${pzo_proc_type}form')]//textarea[contains(@id, '-description')]  ${value}

  Save Tender

Змінити лот value.amount
  [Arguments]  ${value}  ${pzo_proc_type}
  ${converted_num}=  convert_float_to_string  ${value}
  Input text  xpath=//div[contains(@class, 'form-group tender${pzo_proc_type}form-lots-dynamic-forms-wrapper')]//div[contains(@class, 'active')]//div[contains(@class, 'form-group field-lot${pzo_proc_type}form')]//input[contains(@id, '-value_amount')]  ${converted_num}

Змінити лот minimalStep.amount
  [Arguments]  ${value}  ${pzo_proc_type}
  ${converted_num}=  convert_float_to_string  ${value}
  Input text  xpath=//div[contains(@class, 'form-group tender${pzo_proc_type}form-lots-dynamic-forms-wrapper')]//div[contains(@class, 'active')]//div[contains(@class, 'form-group field-lot${pzo_proc_type}form')]//input[contains(@id, '-min_step_amount')]  ${converted_num}

Створити лот із предметом закупівлі
  [Arguments]  ${username}  ${tender_uaid}  ${lot}  ${item}
  Switch browser   ${username}

  ${procurementMethodType}=  Get From Dictionary  ${USERS.users['${PZO_LOGIN_USER}']}  tender_methodtype
  ${pzo_proc_type}=  Convert_to_Lowercase  ${procurementMethodType}

  Open Tender
  Click Element  xpath=//a[contains(@href, '/tender/update?id=')]
  Wait Until Page Contains  Основна інформація  10
  Click Element  xpath=//*[contains(@href, '#collapseLots')]
  Sleep  2
  Click Element  xpath=//a[@href='#add-lots']
  Sleep  2
  Додати лот Ex  ${lot.data}  0  ${procurementMethodType}
  Додати предмет Ex  ${item}  0  ${procurementMethodType}

  Save Tender

Додати предмет закупівлі в лот
  [Arguments]  ${username}  ${tender_uaid}  ${lot_id}  ${item}
  Switch browser   ${username}

  ${procurementMethodType}=  Get From Dictionary  ${USERS.users['${PZO_LOGIN_USER}']}  tender_methodtype
  ${pzo_proc_type}=  Convert_to_Lowercase  ${procurementMethodType}

  Start Edit Lot  ${lot_id}
  Click Element  xpath=//div[contains(@class, 'active')]//a[@href='#add-items']
  Sleep  2
  Додати предмет Ex  ${item}  0  ${procurementMethodType}

  Save Tender

Видалити предмет закупівлі
  [Arguments]  ${username}  ${tender_uaid}  ${item_id}  ${lot_id}
  Switch browser   ${username}

  Start Edit Lot  ${lot_id}
  Click Element  xpath=//div[contains(@class, 'active')]//span[contains(text(), '${item_id}')]
  Sleep  1 
  Click Element  xpath=//li[contains(@data-title, '${item_id}')]//span[@data-confirm-text='Ви впевнені що бажаєте видалити поточний товар/послугу?']
  Sleep  1 
  Click Element  xpath=//div[contains(@class, 'jconfirm-box')]//button[contains(text(), 'Так')]
  Sleep  1 

  Save Tender

Видалити лот
  [Arguments]  ${username}  ${tender_uaid}  ${lot_id}
  Switch browser   ${username}
  Fail  temporary not working
#  Open Tender
#  Click Element  xpath=//a[contains(@href, '/tender/cancel?id=')]
#  Wait Until Page Contains  Скасування закупівлі  10

#  Select From List By Label  xpath=//select[@id='cancellationform-related_of']  Лот
#  Click Element  xpath=//select[@id='cancellationform-related_lot']
#  Click Element  xpath=//select[@id='cancellationform-related_lot']//option[contains(text(), '${lot_id}')]
#  Click Element  xpath=//input[@value='123']
#  Input text  xpath=//textarea[contains(@id, 'cancellationform-reason')]  test

#  Click Element   xpath=//button[contains(text(), 'Скасувати закупівлю')]
#  Sleep  1
#  Click Element   xpath=//button[contains(text(), 'Закрити')]

Додати неціновий показник на тендер
  [Arguments]  ${username}  ${tender_uaid}  ${feature}
  Switch browser   ${username}

  ${procurementMethodType}=  Get From Dictionary  ${USERS.users['${PZO_LOGIN_USER}']}  tender_methodtype
  ${pzo_proc_type}=  Convert_to_Lowercase  ${procurementMethodType}

  Open Tender
  Click Element  xpath=//a[contains(@href, '/tender/update?id=')]
  Wait Until Page Contains  Основна інформація  10
  Click Element  xpath=//h4[contains(@class, 'panel-title')]//*[contains(@href, '#collapseFeatures')]
  Sleep  1
  Add Feature  ${feature}  0  ${procurementMethodType}  div[@id='collapseFeatures']  tenderer

  Save Tender

Видалити неціновий показник
  [Arguments]  ${username}  ${tender_uaid}  ${feature_id}
  Switch browser   ${username}

  ${tender_id}=  Get From Dictionary  ${USERS.users['${PZO_LOGIN_USER}']}  TENDER_ID

  Sync Tender
  Go To  http://dev.pzo.com.ua/tender/update?id=${tender_id}#showfeaturebytext:${feature_id}
  Sleep  2

  Click Element  xpath=//li[contains(@data-title, '${feature_id}')]//span[@data-confirm-text='Ви впевнені що бажаєте видалити поточний неціновий критерій?']
  Sleep  1 
  Click Element  xpath=//div[contains(@class, 'jconfirm-box')]//button[contains(text(), 'Так')]
  Sleep  1 

  Save Tender

Додати неціновий показник на лот
  [Arguments]  ${username}  ${tender_uaid}  ${feature}  ${lot_id}
  Switch browser   ${username}

  ${procurementMethodType}=  Get From Dictionary  ${USERS.users['${PZO_LOGIN_USER}']}  tender_methodtype
  ${pzo_proc_type}=  Convert_to_Lowercase  ${procurementMethodType}

  Start Edit Lot  ${lot_id}
  Add Feature  ${feature}  0  ${procurementMethodType}  div[contains(@class, 'form-group tender${pzo_proc_type}form-lots-dynamic-forms-wrapper')]//div[contains(@class, 'active')]//div[contains(@class, 'form-group lot${pzo_proc_type}form-features-dynamic-forms-wrapper')]  lot

  Save Tender

Додати неціновий показник на предмет
  [Arguments]  ${username}  ${tender_uaid}  ${feature}  ${item_id}
  Switch browser   ${username}

  ${procurementMethodType}=  Get From Dictionary  ${USERS.users['${PZO_LOGIN_USER}']}  tender_methodtype
  ${pzo_proc_type}=  Convert_to_Lowercase  ${procurementMethodType}
  ${tender_id}=  Get From Dictionary  ${USERS.users['${PZO_LOGIN_USER}']}  TENDER_ID

  Sync Tender
  Go To  http://dev.pzo.com.ua/tender/update?id=${tender_id}#showitembytext:${item_id}
  Sleep  2
  Add Feature  ${feature}  0  ${procurementMethodType}  div[contains(@class, 'form-group tender${pzo_proc_type}form-lots-dynamic-forms-wrapper')]//div[contains(@class, 'active')]//div[contains(@class, 'form-group lot${pzo_proc_type}form-items-dynamic-forms-wrapper')]//div[contains(@class, 'item${pzo_proc_type}form-features-dynamic-forms-wrapper')]  item
  
  Save Tender

Відповісти на запитання
  [Arguments]  ${username}  ${tender_uaid}  ${answer}  ${question_id}
  Switch browser   ${username}

  ${tender_id}=  Get From Dictionary  ${USERS.users['${PZO_LOGIN_USER}']}  TENDER_ID

  Sync Tender
  Go To  http://dev.pzo.com.ua/tender/question-answer?id=${tender_id}
  Click Element  xpath=//select[@id='questionanswerform-question']
  Click Element  xpath=//select[@id='questionanswerform-question']//option[contains(text(), '${question_id}')]
  Input text  xpath=//textarea[contains(@id, 'questionanswerform-answer')]  ${answer.data.answer}

  Click Element   xpath=//button[contains(text(), 'Надати відповідь')]
  Sleep  1
  Click Element   xpath=//button[contains(text(), 'Закрити')]

Відповісти на вимогу
  [Arguments]  ${username}  ${tender_uaid}  ${claim_id}  ${answer}  ${award_index}
  Switch browser   ${username}

  ${tender_id}=  Get From Dictionary  ${USERS.users['${PZO_LOGIN_USER}']}  TENDER_ID

  Sync Tender
  Go To  http://dev.pzo.com.ua/tender/complaint-answer?id=${tender_id}
#  Click Element  xpath=//select[@id='complaintanswerform-complaint']
#  Click Element  xpath=//select[@id='complaintanswerform-complaint']//option[contains(text(), '${claim_id}')]
  Input text  xpath=//textarea[contains(@id, 'complaintanswerform-resolution')]  ${answer.data.resolution}
  Run Keyword If  '${answer.data.resolutionType}' == 'resolved'  Select From List By Label  xpath=//select[@id='complaintanswerform-resolution_type']  Задоволено
  Run Keyword If  '${answer.data.resolutionType}' == 'declined'  Select From List By Label  xpath=//select[@id='complaintanswerform-resolution_type']  Відхилено
  Run Keyword If  '${answer.data.resolutionType}' == 'invalid'  Select From List By Label  xpath=//select[@id='complaintanswerform-resolution_type']  Не задоволено
  Input text  xpath=//textarea[contains(@id, 'complaintanswerform-tenderer_action')]  ${answer.data.tendererAction}

  Click Element   xpath=//button[contains(text(), 'Надати відповідь')]
  Sleep  1
  Click Element   xpath=//button[contains(text(), 'Закрити')]
  
Відповісти на вимогу про виправлення умов закупівлі
  [Arguments]  ${username}  ${tender_uaid}  ${claim_id}  ${answer}
  Відповісти на вимогу  ${username}  ${tender_uaid}  ${claim_id}  ${answer}  null

Відповісти на вимогу про виправлення умов лоту
  [Arguments]  ${username}  ${tender_uaid}  ${claim_id}  ${answer}
  Відповісти на вимогу  ${username}  ${tender_uaid}  ${claim_id}  ${answer}  null

Відповісти на вимогу про виправлення визначення переможця
  [Arguments]  ${username}  ${tender_uaid}  ${claim_id}  ${answer}  ${award_index}
  Відповісти на вимогу  ${username}  ${tender_uaid}  ${claim_id}  ${answer}  ${award_index}

Завантажити документ у кваліфікацію
  [Arguments]  ${username}  ${doc_name}  ${tender_uaid}  ${proposal_id}
  Switch browser   ${username}
  ${doc_contents}=  Get File  ${doc_name}
  Set To Dictionary  ${USERS.users['${PZO_LOGIN_USER}']}  proposal${proposal_id}_document=${doc_name}
  Set To Dictionary  ${USERS.users['${PZO_LOGIN_USER}']}  proposal${proposal_id}_document_contents=${doc_contents}

Відхилити кваліфікацію
  [Arguments]  ${username}  ${tender_uaid}  ${proposal_id}
  Switch browser   ${username}
  Fail  temporary not working

Скасувати кваліфікацію
  [Arguments]  ${username}  ${tender_uaid}  ${proposal_id}
  Switch browser   ${username}
  Fail  temporary not working

Підтвердити кваліфікацію
  [Arguments]  ${username}  ${tender_uaid}  ${proposal_id}
  Switch browser   ${username}

  #workaround
  ${proposal_id} =  Set Variable If  '-1' == '${proposal_id}'  1  ${proposal_id}

  ${doc_name}=  Get From Dictionary  ${USERS.users['${PZO_LOGIN_USER}']}  proposal${proposal_id}_document
  ${doc_contents}=  Get From Dictionary  ${USERS.users['${PZO_LOGIN_USER}']}  proposal${proposal_id}_document_contents
  Create File  ${doc_name}  ${doc_contents}

  Open Tender
  Click Element  xpath=//div[contains(@class, 'aside-menu ')]//a[contains(@href, '/tender/prequalification?id=')]
  Wait Until Page Contains  Прекваліфікація  10
  Click Element  id=prequalificationform-qualification
#  Click Element  jquery=select#prequalificationform-qualification option:eq(${proposal_id})
  Click Element  jquery=select#prequalificationform-qualification option:eq(0)
  Select From List By Label  xpath=//select[@id='prequalificationform-decision']  Підтвердити
  Choose File  xpath=//input[@type='file']  ${doc_name}
  Sleep  2
  Click Element  id=prequalificationform-eligible
  Click Element  id=prequalificationform-qualified

  Click Button  xpath=//*[text()='Завантажити рішення']
  Wait Until Page Contains  Рішення завантажене  10
  Sleep  1
  Click Button  xpath=//*[text()='Закрити']
  Sleep  3

  Capture Page Screenshot
  Click Button  xpath=//*[text()='Накласти ЕЦП']
  Sleep  1
  Load Sign
  Wait Until Page Contains  ЕЦП успішно накладено на рішення  10
  Click Button  xpath=//*[text()='Закрити']
  Sleep  3

  Click Button  xpath=//*[text()='Підтвердити рішення']
  Sleep  1
  Wait Until Page Contains  Рішення підтверджене  10
  Sleep  3

  Open Tender
  Remove File  ${doc_name}

Затвердити остаточне рішення кваліфікації
  [Arguments]  ${username}  ${tender_uaid}
  Switch browser   ${username}

  Open Tender
  Click Element  xpath=//a[contains(@href, '/tender/prequalification-approve?id=')]
  Sleep  1
  Click Button  xpath=//*[text()='Так']
  Wait Until Page Contains  Прекваліфікація підтверджена  10
  Click Button  xpath=//*[text()='Закрити']

Задати запитання
  [Arguments]  ${username}  ${tender_uaid}  ${type}  ${type_id}  ${question}
  Switch browser   ${username}
  Open Tender
  Click Element  xpath=//a[contains(@href, '/tender/question-create?id=')]
  Wait Until Page Contains  Нове запитання до закупівлі  10
  Run Keyword If  '${type}' == 'tender'  Select From List By Label  xpath=//select[@id='questionform-related_of']  Закупівля
  Run Keyword If  '${type}' == 'lot'  Select From List By Label  xpath=//select[@id='questionform-related_of']  Лот
  Run Keyword If  '${type}' == 'lot'  Click Element  xpath=//select[@id='questionform-related_lot']
  Run Keyword If  '${type}' == 'lot'  Click Element  xpath=//select[@id='questionform-related_lot']//option[contains(text(), '${type_id}')]
  Run Keyword If  '${type}' == 'item'  Select From List By Label  xpath=//select[@id='questionform-related_of']  Предмет закупівлі
  Run Keyword If  '${type}' == 'item'  Click Element  xpath=//select[@id='questionform-related_item']
  Run Keyword If  '${type}' == 'item'  Click Element  xpath=//select[@id='questionform-related_item']//option[contains(text(), '${type_id}')]
  Input text  xpath=//input[contains(@id, 'questionform-title')]  ${question.data.title}
  Input text  xpath=//textarea[contains(@id, 'questionform-description')]  ${question.data.description}
  Click Element   xpath=//button[contains(text(), 'Задати питання')]
  Sleep  1
  Click Element   xpath=//button[contains(text(), 'Закрити')]

Задати запитання на тендер
  [Arguments]  ${username}  ${tender_uaid}  ${question}
  Задати запитання  ${username}  ${tender_uaid}  tender  null  ${question}
  
Задати запитання на лот
  [Arguments]  ${username}  ${tender_uaid}  ${lot_id}  ${question}
  Задати запитання  ${username}  ${tender_uaid}  lot  ${lot_id}  ${question}

Задати запитання на предмет
  [Arguments]  ${username}  ${tender_uaid}  ${item_id}  ${question}
  Задати запитання  ${username}  ${tender_uaid}  item  ${item_id}  ${question}

Wait For Complaints Sync
  Sleep  5
  Reload Page
  Page Should Not Contain Element  xpath=//i[@class='fa fa-spin fa-refresh']

Створити вимогу
  [Arguments]  ${username}  ${tender_uaid}  ${type}  ${type_id}  ${claim}  ${doc_name}
  Switch browser  ${username}
  Open Tender
  Capture Page Screenshot
  Click Element  xpath=//a[contains(@href, '/tender/complaint-create?id=')]
  Run Keyword And Ignore Error  Wait Until Page Contains Element  xpath=//select[@id='complaintform-related_of']  10
  Run Keyword And Ignore Error  Run Keyword If  '${type}' == 'tender'  Select From List By Label  xpath=//select[@id='complaintform-related_of']  Закупівля
  Run Keyword And Ignore Error  Run Keyword If  '${type}' == 'lot'  Select From List By Label  xpath=//select[@id='complaintform-related_of']  Лот
  Run Keyword And Ignore Error  Run Keyword If  '${type}' == 'lot'  Click Element  xpath=//select[@id='complaintform-related_lot']
  Run Keyword And Ignore Error  Run Keyword If  '${type}' == 'lot'  Click Element  xpath=//select[@id='complaintform-related_lot']//option[contains(text(), '${type_id}')]
  Run Keyword And Ignore Error  Select From List By Label  xpath=//select[@id='complaintform-type']  Вимога
  Input text  xpath=//input[contains(@id, 'complaintform-title')]  ${claim.data.title}
  Input text  xpath=//textarea[contains(@id, 'complaintform-description')]  ${claim.data.description}
  Run Keyword If  '${doc_name}' != 'null'  Click Element  xpath=//a[contains(@data-url, '/tender/get-complaint-document-form')]
  Run Keyword If  '${doc_name}' != 'null'  Wait Until Page Contains Element  xpath=//input[@type='file']  10
  Run Keyword If  '${doc_name}' != 'null'  Choose File  xpath=//input[@type='file']  ${doc_name}
  Run Keyword If  '${doc_name}' != 'null'  Sleep  2
  Click Element   xpath=//button[contains(text(), 'Створити')]
  Sleep  1
  Click Element   xpath=//button[contains(text(), 'Закрити')]
  #
  Open Tender
  Switch To Complaints
  ${passed}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  360 s  0 s  Wait For Complaints Sync
  Run Keyword Unless  ${passed}  Fatal Error  Sync not completed in 360 sec
  #
  ${return_value}=  Get Element Attribute  xpath=//div[@id='tender-complaint-list']//a[contains(@href,'#collapseComplaint')]@data-complaint-id
  ${return_value}=  Convert To String  ${return_value}
  [return]  ${return_value}
  
Створити вимогу про виправлення умов закупівлі
  [Arguments]  ${username}  ${tender_uaid}  ${claim}  ${doc_name}
  Run Keyword And Return  Створити вимогу  ${username}  ${tender_uaid}  tender  null  ${claim}  ${doc_name}

Створити чернетку вимоги про виправлення умов закупівлі
  [Arguments]  ${username}  ${tender_uaid}  ${claim}
  Run Keyword And Return  Створити вимогу  ${username}  ${tender_uaid}  tender  null  ${claim}  null

Створити вимогу про виправлення умов лоту
  [Arguments]  ${username}  ${tender_uaid}  ${claim}  ${lot_id}  ${doc_name}
  Run Keyword And Return  Створити вимогу  ${username}  ${tender_uaid}  lot  ${lot_id}  ${claim}  ${doc_name}

Створити чернетку вимоги про виправлення умов лоту
  [Arguments]  ${username}  ${tender_uaid}  ${claim}  ${lot_id}
  Run Keyword And Return  Створити вимогу  ${username}  ${tender_uaid}  lot  ${lot_id}  ${claim}  null

Створити вимогу про виправлення визначення переможця
  [Arguments]  ${username}  ${tender_uaid}  ${claim}  ${proposal_id}  ${doc_name}
  Run Keyword And Return  Створити вимогу  ${username}  ${tender_uaid}  winner  ${proposal_id}  ${claim}  ${doc_name}

Створити чернетку вимоги про виправлення визначення переможця
  [Arguments]  ${username}  ${tender_uaid}  ${claim}  ${proposal_id}
  Run Keyword And Return  Створити вимогу  ${username}  ${tender_uaid}  winner  ${proposal_id}  ${claim}  null

Скасувати вимогу
  [Arguments]  ${username}  ${tender_uaid}  ${claim_id}  ${data}  ${award_index}
  Switch browser  ${username}
  Open Tender
  Switch To Complaints
  Collapse Complaint  ${claim_id}
  Click Element   xpath=//div[@id='tender-complaint-list']//div[@data-complaint-id='${claim_id}']//a[contains(@href, '/tender/complaint-cancel?complaint=')]
  Input text  xpath=//textarea[contains(@id, 'complaintcancelform-cancellation_reason')]  ${data.data.cancellationReason}
  Capture Page Screenshot
  Click Element   xpath=//button[contains(text(), 'Відкликати')]
  Sleep  1
  Click Element   xpath=//button[contains(text(), 'Закрити')]

Скасувати вимогу про виправлення умов закупівлі
  [Arguments]  ${username}  ${tender_uaid}  ${claim_id}  ${data}
  Скасувати вимогу  ${username}  ${tender_uaid}  ${claim_id}  ${data}  null

Скасувати вимогу про виправлення умов лоту
  [Arguments]  ${username}  ${tender_uaid}  ${claim_id}  ${data}
  Скасувати вимогу  ${username}  ${tender_uaid}  ${claim_id}  ${data}  null

Скасувати вимогу про виправлення визначення переможця
  [Arguments]  ${username}  ${tender_uaid}  ${claim_id}  ${data}  ${award_index}
  Скасувати вимогу  ${username}  ${tender_uaid}  ${claim_id}  ${data}  ${award_index}

Підтвердити вирішення вимоги
  [Arguments]  ${username}  ${tender_uaid}  ${type}  ${type_id}  ${claim}  ${data}  ${award_index}
  Switch browser  ${username}
  ${tender_id}=  Get From Dictionary  ${USERS.users['${PZO_LOGIN_USER}']}  TENDER_ID
  Open Tender
  Go To  http://dev.pzo.com.ua/tender/complaint-resolve?id=${tender_id}
  Wait Until Page Contains Element  xpath=//select[@id='complaintresolveform-complaint']  10
  Click Element  xpath=//select[@id='complaintresolveform-complaint']
  Click Element  xpath=//select[@id='complaintresolveform-complaint']//option[@data-complaintid='${claim}']
  Run Keyword If  '${data.data.status}' == 'resolved'  Select From List By Label  xpath=//select[@id='complaintresolveform-satisfied']  Задовільнена
  Run Keyword If  '${data.data.status}' == 'declined'  Select From List By Label  xpath=//select[@id='complaintresolveform-satisfied']  Не задовільнена
  Run Keyword If  '${data.data.status}' == 'invalid'  Select From List By Label  xpath=//select[@id='complaintresolveform-satisfied']  Не задовільнена
  Run Keyword If  '${data.data.status}' == 'pending'  Select From List By Label  xpath=//select[@id='complaintresolveform-satisfied']  Не задовільнена
  Click Element   xpath=//button[contains(text(), 'Надати рішення')]
  Sleep  1
  Click Element   xpath=//button[contains(text(), 'Закрити')]

Підтвердити вирішення вимоги про виправлення умов закупівлі
  [Arguments]  ${username}  ${tender_uaid}  ${claim}  ${data}
  Підтвердити вирішення вимоги  ${username}  ${tender_uaid}  tender  null  ${claim}  ${data}  null

Підтвердити вирішення вимоги про виправлення умов лоту
  [Arguments]  ${username}  ${tender_uaid}  ${claim}  ${data}
  Підтвердити вирішення вимоги  ${username}  ${tender_uaid}  lot  null  ${claim}  ${data}  null

Підтвердити вирішення вимоги про виправлення визначення переможця
  [Arguments]  ${username}  ${tender_uaid}  ${claim}  ${data}  ${award_index}
  Підтвердити вирішення вимоги  ${username}  ${tender_uaid}  award  null  ${claim}  ${data}  ${award_index}

Перетворити вимогу про виправлення умов закупівлі в скаргу
  [Arguments]  ${username}  ${tender_uaid}  ${claim_id}  ${escalation_data}
  Підтвердити вирішення вимоги  ${username}  ${tender_uaid}  lot  null  ${claim_id}  ${escalation_data}  null

Перетворити вимогу про виправлення умов лоту в скаргу
  [Arguments]  ${username}  ${tender_uaid}  ${claim}  ${data}
  Підтвердити вирішення вимоги  ${username}  ${tender_uaid}  lot  null  ${claim}  ${data}  null

Перетворити вимогу про виправлення визначення переможця в скаргу
  [Arguments]  ${username}  ${tender_uaid}  ${claim_id}  ${escalation_data}  ${award_index}
  Підтвердити вирішення вимоги  ${username}  ${tender_uaid}  award  null  ${claim_id}  ${escalation_data}  ${award_index}

Подати цінову пропозицію
  [Arguments]  ${username}  ${tender_uaid}  ${bid}  ${lots_ids}  ${features_ids}

  ${bid_data_keys}=  Get Dictionary Keys  ${bid.data}

  Run Keyword If  'lotValues' in ${bid_data_keys}  Подати цінову пропозицію Lots  ${username}  ${tender_uaid}  ${bid}  ${lots_ids}  ${features_ids}
  Run Keyword If  'lotValues' not in ${bid_data_keys}  Подати цінову пропозицію No Lots  ${username}  ${tender_uaid}  ${bid}  ${lots_ids}  ${features_ids}

  Click Element   xpath=//button[contains(text(), 'Подати пропозицію')]
  Sleep  1
  Click Element   xpath=//button[contains(text(), 'Закрити')]
  Sleep  2
  Wait For All Transfer Complete

Подати цінову пропозицію Lots
  [Arguments]  ${username}  ${tender_uaid}  ${bid}  ${lots_ids}  ${features_ids}
  Switch browser  ${username}

  ${tender_id}=  Get From Dictionary  ${USERS.users['${PZO_LOGIN_USER}']}  TENDER_ID
  ${lots}=  Get From Dictionary  ${bid.data}  lotValues
  ${lots_length}=  Get Length  ${lots}

  Open Tender
  ${procurementMethodType}=  Отримати інформацію із тендера procurementMethodType

  : FOR    ${INDEX}    IN RANGE    0    ${lots_length}
  \   Set To Dictionary  ${USERS.users['${PZO_LOGIN_USER}']}  last_proposal_lotid=${lots[${INDEX}].relatedLot}
  \   Go To  http://dev.pzo.com.ua/tender/bid?id=${tender_id}#showlotbykey:${lots[${INDEX}].relatedLot}
  \   Sleep  2
  \   Подати цінову пропозицію Amount  ${lots[${INDEX}].value.amount}
  \   Run Keyword If  '${procurementMethodType}' != 'belowThreshold'  Input text  xpath=//div[contains(@class, 'active')]//textarea[contains(@id, '-subcontracting_details')]  ${bid.data.tenderers[0].name}
  \   Run Keyword If  '${procurementMethodType}' != 'belowThreshold'  Click Element  xpath=//div[contains(@class, 'active')]//input[contains(@id, '-self_eligible')]
  \   Run Keyword If  '${procurementMethodType}' != 'belowThreshold'  Click Element  xpath=//div[contains(@class, 'active')]//input[contains(@id, '-self_qualified')]
  \   Run Keyword If  '${procurementMethodType}' != 'belowThreshold'  Подати цінову пропозицію Features  ${bid.data.parameters}
  \   Run Keyword If  '${procurementMethodType}' != 'belowThreshold'  Run Keyword If  '${procurementMethodType}' != 'aboveThresholdUA'  Подати цінову пропозицію FakeDocs

Подати цінову пропозицію No Lots
  [Arguments]  ${username}  ${tender_uaid}  ${bid}  ${lots_ids}  ${features_ids}
  Switch browser  ${username}

  ${tender_id}=  Get From Dictionary  ${USERS.users['${PZO_LOGIN_USER}']}  TENDER_ID

  Open Tender
  Go To  http://dev.pzo.com.ua/tender/bid?id=${tender_id}
  Sleep  2
  ${amount}=  convert_float_to_string  ${bid.data.value.amount}
  Input text  xpath=//input[contains(@id, '-value_amount')]  ${amount}

Подати цінову пропозицію Amount
  [Arguments]  ${amount}
  ${amount}=  convert_float_to_string  ${amount}
  Input text  xpath=//div[contains(@class, 'active')]//input[contains(@id, '-value_amount')]  ${amount}

Подати цінову пропозицію Features
  [Arguments]  ${features}
  ${tender_id}=  Get From Dictionary  ${USERS.users['${PZO_LOGIN_USER}']}  TENDER_ID
  ${features_length}=  Get Length  ${features}
  : FOR    ${INDEX}    IN RANGE    0    ${features_length}
  \   Run Keyword And Ignore Error  Click Element  xpath=//select[contains(@data-opid, '${features[${INDEX}]['code']}')]
  \   Run Keyword And Ignore Error  Click Element  xpath=//select[contains(@data-opid, '${features[${INDEX}]['code']}')]//option[contains(@data-weight-source, '${features[${INDEX}]['value']}')]

Подати цінову пропозицію FakeDocs
  ${file_path}  ${file_name}  ${file_content}=  create_fake_doc
  ${file_path_2}  ${file_name_2}  ${file_content_2}=  create_fake_doc
  Click Element  xpath=//div[contains(@class, 'active')]//a[contains(@href, '#add-documents')]
  Sleep  2
  Choose File  xpath=//div[contains(@class, 'active')]//div[contains(@class, 'active')]//input[@type='file']  ${file_path}
  Sleep  2
  Select From List By Label  xpath=//div[contains(@class, 'active')]//div[contains(@class, 'active')]//select[contains(@id, '-document_type')]  Підтвердження відповідності кваліфікаційним критеріям
  Input text  xpath=//div[contains(@class, 'active')]//div[contains(@class, 'active')]//textarea[contains(@id, '-description')]  test
  Sleep  1
  Click Element  xpath=//div[contains(@class, 'active')]//a[contains(@href, '#add-documents')]
  Sleep  2
  Choose File  xpath=//div[contains(@class, 'active')]//div[contains(@class, 'active')]//input[@type='file']  ${file_path_2}
  Sleep  2
  Select From List By Label  xpath=//div[contains(@class, 'active')]//div[contains(@class, 'active')]//select[contains(@id, '-document_type')]  Кошторис
  Input text  xpath=//div[contains(@class, 'active')]//div[contains(@class, 'active')]//textarea[contains(@id, '-description')]  test2
  Sleep  1

Start Edit Proposal
  ${no_lotid}=  Run Keyword And Return Status  Dictionary Should Not Contain Key  ${USERS.users['${PZO_LOGIN_USER}']}  last_proposal_lotid
  Sync Tender
  Run Keyword If  ${no_lotid} == True  Start Edit Proposal Whole
  Run Keyword If  ${no_lotid} == False  Start Edit Proposal Lot
  Sleep  2

Start Edit Proposal Whole
  ${tender_id}=  Get From Dictionary  ${USERS.users['${PZO_LOGIN_USER}']}  TENDER_ID
  Go To  http://dev.pzo.com.ua/tender/bid?id=${tender_id}

Start Edit Proposal Lot
  ${tender_id}=  Get From Dictionary  ${USERS.users['${PZO_LOGIN_USER}']}  TENDER_ID
  ${last_proposal_lotid}=  Get From Dictionary  ${USERS.users['${PZO_LOGIN_USER}']}  last_proposal_lotid
  Go To  http://dev.pzo.com.ua/tender/bid?id=${tender_id}#showlotbykey:${last_proposal_lotid}

Save Proposal
  Click Element   xpath=//button[contains(text(), 'Редагувати пропозицію')]
  Sleep  1
  Click Element   xpath=//button[contains(text(), 'Закрити')]
  Sleep  2
  Wait For All Transfer Complete

Завантажити документ в ставку
  [Arguments]  ${username}  @{arguments}
  [Documentation]
  ...      ${arguments[0]} ==  file_path
  ...      ${arguments[1]} ==  tender_uaid
  ...      ${arguments[2]} ==  doc_type
  Switch browser  ${username}
  Start Edit Proposal
  ${no_lotid}=  Run Keyword And Return Status  Dictionary Should Not Contain Key  ${USERS.users['${PZO_LOGIN_USER}']}  last_proposal_lotid
  #
  Run Keyword If  ${no_lotid} == False  Click Element  xpath=//div[contains(@class, 'active')]//a[contains(@href, '#add-documents')]
  Run Keyword If  ${no_lotid} == True  Click Element  xpath=//a[contains(@href, '#add-documents')]
  Sleep  2
  Run Keyword If  ${no_lotid} == False  Choose File  xpath=//div[contains(@class, 'active')]//div[contains(@class, 'active')]//input[@type='file']  ${arguments[0]}
  Run Keyword If  ${no_lotid} == True  Choose File  xpath=//div[contains(@class, 'active')]//input[@type='file']  ${arguments[0]}
  Sleep  2
  Run Keyword If  ${no_lotid} == False  Select From List By Label  xpath=//div[contains(@class, 'active')]//div[contains(@class, 'active')]//select[contains(@id, '-document_type')]  Технічний опис предмету закупівлі
  Run Keyword If  ${no_lotid} == True  Select From List By Label  xpath=//div[contains(@class, 'active')]//select[contains(@id, '-document_type')]  Технічний опис предмету закупівлі
  Run Keyword If  ${no_lotid} == False  Run Keyword And Ignore Error  Run Keyword If  '${arguments[2]}' == 'financial_documents'  Select From List By Label  xpath=//div[contains(@class, 'active')]//div[contains(@class, 'active')]//select[contains(@id, '-document_type')]  Цінова пропозиція
  Run Keyword If  ${no_lotid} == True  Run Keyword And Ignore Error  Run Keyword If  '${arguments[2]}' == 'financial_documents'  Select From List By Label  xpath=//div[contains(@class, 'active')]//select[contains(@id, '-document_type')]  Цінова пропозиція
  Run Keyword If  ${no_lotid} == False  Run Keyword And Ignore Error  Run Keyword If  '${arguments[2]}' == 'qualification_documents'  Select From List By Label  xpath=//div[contains(@class, 'active')]//div[contains(@class, 'active')]//select[contains(@id, '-document_type')]  Підтвердження відповідності кваліфікаційним критеріям
  Run Keyword If  ${no_lotid} == True  Run Keyword And Ignore Error  Run Keyword If  '${arguments[2]}' == 'qualification_documents'  Select From List By Label  xpath=//div[contains(@class, 'active')]//select[contains(@id, '-document_type')]  Підтвердження відповідності кваліфікаційним критеріям
  Run Keyword If  ${no_lotid} == False  Run Keyword And Ignore Error  Run Keyword If  '${arguments[2]}' == 'eligibility_documents'  Select From List By Label  xpath=//div[contains(@class, 'active')]//div[contains(@class, 'active')]//select[contains(@id, '-document_type')]  Документи, що підтверджують відповідність (в тому числі, відповідність вимогам ст. 17)
  Run Keyword If  ${no_lotid} == True  Run Keyword And Ignore Error  Run Keyword If  '${arguments[2]}' == 'eligibility_documents'  Select From List By Label  xpath=//div[contains(@class, 'active')]//select[contains(@id, '-document_type')]  Документи, що підтверджують відповідність (в тому числі, відповідність вимогам ст. 17)
  Run Keyword If  ${no_lotid} == False  Input text  xpath=//div[contains(@class, 'active')]//div[contains(@class, 'active')]//textarea[contains(@id, '-description')]  test
  Run Keyword If  ${no_lotid} == True  Input text  xpath=//div[contains(@class, 'active')]//textarea[contains(@id, '-description')]  test
  Sleep  1

  Save Proposal
  
Змінити документ в ставці
  [Arguments]  ${username}  ${tender_uaid}  ${file_path}  ${doc_id}
  Switch browser  ${username}
  Start Edit Proposal
  ${no_lotid}=  Run Keyword And Return Status  Dictionary Should Not Contain Key  ${USERS.users['${PZO_LOGIN_USER}']}  last_proposal_lotid
  #
  Run Keyword If  ${no_lotid} == False  Run Keyword And Ignore Error  Click Element  xpath=//div[contains(@class, 'active')]//li[contains(@data-title, '${doc_id}')]
  Run Keyword If  ${no_lotid} == True  Run Keyword And Ignore Error  Click Element  xpath=//li[contains(@data-title, '${doc_id}')]
  Run Keyword If  ${no_lotid} == False  Run Keyword And Ignore Error  Click Element  xpath=//div[contains(@class, 'active')]//li[contains(@data-titles, '${doc_id}')]
  Run Keyword If  ${no_lotid} == True  Run Keyword And Ignore Error  Click Element  xpath=//li[contains(@data-titles, '${doc_id}')]
  Sleep  1
  Run Keyword If  ${no_lotid} == False  Choose File  xpath=//div[contains(@class, 'active')]//div[contains(@class, 'active')]//input[@type='file']  ${file_path}
  Run Keyword If  ${no_lotid} == True  Choose File  xpath=//div[contains(@class, 'active')]//input[@type='file']  ${file_path}
  Sleep  2

  Save Proposal

Змінити документацію в ставці
  [Arguments]  ${username}  ${tender_uaid}  ${data}  ${doc_id}
  Switch browser  ${username}
  Start Edit Proposal
  Run Keyword And Ignore Error  Click Element  xpath=//div[contains(@class, 'active')]//li[contains(@data-title, '${doc_id}')]
  Run Keyword And Ignore Error  Click Element  xpath=//div[contains(@class, 'active')]//li[contains(@data-titles, '${doc_id}')]
  Sleep  1
  Click Element  xpath=//div[contains(@class, 'active')]//div[contains(@class, 'active')]//input[contains(@id, '-confidentiality')]
  Sleep  1
  Input text  xpath=//div[contains(@class, 'active')]//div[contains(@class, 'active')]//textarea[contains(@id, '-confidentiality_rationale')]  ${data.data.confidentialityRationale}
  Sleep  1

  Save Proposal

Змінити цінову пропозицію
  [Arguments]  ${username}  ${tender_uaid}  ${field}  ${value}
  Switch browser  ${username}
  Start Edit Proposal
  Run Keyword If  '${field}' == 'lotValues[0].value.amount'  Подати цінову пропозицію Amount  ${value}
#  Run Keyword If  '${field}' == 'status'  xxx
  Sleep  1

  Save Proposal

Завантажити документ рішення кваліфікаційної комісії
  [Arguments]  ${username}  ${doc_name}  ${tender_uaid}  ${award_index}
  Switch browser   ${username}
  Set To Dictionary  ${USERS.users['${PZO_LOGIN_USER}']}  qproposal${award_index}_document=${doc_name}

Підтвердити постачальника
  [Arguments]  ${username}  ${tender_uaid}  ${award_index}
  Switch browser   ${username}

  ${doc_name}=  Get From Dictionary  ${USERS.users['${PZO_LOGIN_USER}']}  qproposal${award_index}_document

  Open Tender
  Click Element  xpath=//div[contains(@class, 'aside-menu ')]//a[contains(@href, '/tender/qualification?id=')]
  Wait Until Page Contains  Кваліфікація  10
  Click Element  id=qualificationform-award
  Click Element  jquery=select#qualificationform-award option:eq(0)
  Select From List By Label  xpath=//select[@id='qualificationform-decision']  Визначити переможною
  Choose File  xpath=//input[@type='file']  ${doc_name}
  Sleep  2
  Select From List By Label  xpath=//select[contains(@id, '-document_type')]  Повідомлення про рішення

  Click Button  xpath=//*[text()='Підтвердити рішення']
  Wait Until Page Contains  Пропозиція прийнята  10
  Sleep  1
  Click Button  xpath=//*[text()='Закрити']
  Sleep  2





# --------------------------------------------------------- #



Отримати інформацію із тендера
  [Arguments]  @{arguments}
  [Documentation]
  ...      ${arguments[0]} ==  username
  ...      ${arguments[1]} ==  tender_uaid
  ...      ${arguments[2]} ==  fieldname
  Switch browser   ${arguments[0]}

#  Log To Console  ''
#  Log To Console  Отримати інформацію із тендера
#  Log To Console  ${arguments[1]}
#  Log To Console  ${arguments[2]}

  Run Keyword And Return If   'deliveryLocation.longitude' == '${arguments[2]}'   Fail  Не реалізований функціонал
  Run Keyword And Return If   'deliveryLocation.latitude' == '${arguments[2]}'   Fail  Не реалізований функціонал
  Run Keyword And Return If   'tenderPeriod.startDate' == '${arguments[2]}'   Отримати інформацію із тендера tenderPeriod.startDate
  Run Keyword And Return If   'tenderPeriod.endDate' == '${arguments[2]}'   Отримати інформацію із тендера tenderPeriod.endDate
  Run Keyword And Return If   'procurementMethodType' == '${arguments[2]}'   Отримати інформацію із тендера procurementMethodType
  Run Keyword And Return If   'value.amount' == '${arguments[2]}'   Отримати інформацію із тендера value.amount
  Run Keyword And Return If   'status' == '${arguments[2]}'   Отримати інформацію із тендера status
  Run Keyword And Return If   'enquiryPeriod.startDate' == '${arguments[2]}'   Отримати інформацію із тендера enquiryPeriod.startDate
  Run Keyword And Return If   'enquiryPeriod.endDate' == '${arguments[2]}'   Отримати інформацію із тендера enquiryPeriod.endDate
  Run Keyword And Return If   'complaintPeriod.startDate' == '${arguments[2]}'   Отримати інформацію із тендера complaintPeriod.startDate
  Run Keyword And Return If   'complaintPeriod.endDate' == '${arguments[2]}'   Отримати інформацію із тендера complaintPeriod.endDate
  Run Keyword And Return If   'title' == '${arguments[2]}'   Отримати інформацію із тендера title
  Run Keyword And Return If   'description' == '${arguments[2]}'   Отримати інформацію із тендера description
  Run Keyword And Return If   'value.currency' == '${arguments[2]}'   Отримати інформацію із тендера value.currency
  Run Keyword And Return If   'value.valueAddedTaxIncluded' == '${arguments[2]}'   Отримати інформацію із тендера value.valueAddedTaxIncluded
  Run Keyword And Return If   'tenderID' == '${arguments[2]}'   Отримати інформацію із тендера tenderID
  Run Keyword And Return If   'procuringEntity.name' == '${arguments[2]}'   Отримати інформацію із тендера procuringEntity.name
  Run Keyword And Return If   'minimalStep.amount' == '${arguments[2]}'   Отримати інформацію із тендера minimalStep.amount
  Run Keyword And Return If   'bids' == '${arguments[2]}'   Fail  Unable to see bids
  Run Keyword And Return If   'qualifications[0].status' == '${arguments[2]}'  Отримати інформацію із тендера qualifications[0].status
  Run Keyword And Return If   'qualifications[1].status' == '${arguments[2]}'  Отримати інформацію із тендера qualifications[1].status
  Run Keyword If   'qualificationPeriod.endDate' == '${arguments[2]}'  Open Tender
  Run Keyword And Return If   'qualificationPeriod.endDate' == '${arguments[2]}'  Отримати інформацію із тендера qualificationPeriod.endDate
  Run Keyword And Return If   'procuringEntity.identifier.id' == '${arguments[2]}'   Get invisible text by locator  jquery=div#procuringentityinfo p.identifier-code
  Run Keyword And Return If   'procuringEntity.identifier.legalName' == '${arguments[2]}'   Get text by locator  jquery=div#procuringentityinfo p.legal-name .value
  Run Keyword And Return If   'procuringEntity.address.region' == '${arguments[2]}'   Get invisible text by locator  jquery=div#procuringentityinfo p.region
  Run Keyword And Return If   'procuringEntity.address.locality' == '${arguments[2]}'   Get invisible text by locator  jquery=div#procuringentityinfo p.locality
  Run Keyword And Return If   'procuringEntity.address.streetAddress' == '${arguments[2]}'   Get invisible text by locator  jquery=div#procuringentityinfo p.street-address
  Run Keyword And Return If   'procuringEntity.contactPoint.name' == '${arguments[2]}'   Get text by locator  jquery=div#procuringentitycontactpointinfo p.name span.value
  Run Keyword And Return If   'procuringEntity.contactPoint.email' == '${arguments[2]}'   Get text by locator  jquery=div#procuringentitycontactpointinfo p.email span.value
  Run Keyword And Return If   'procuringEntity.contactPoint.telephone' == '${arguments[2]}'   Get text by locator  jquery=div#procuringentitycontactpointinfo p.phone span.value
  Run Keyword And Return If   'procuringEntity.contactPoint.faxNumber' == '${arguments[2]}'   Get text by locator  jquery=div#procuringentitycontactpointinfo p.fax span.value
  Run Keyword And Return If   'procuringEntity.contactPoint.url' == '${arguments[2]}'   Get text by locator  jquery=div#procuringentitycontactpointinfo p.website span.value
# awards complaint end date
  ${Result}=  Run Keyword And Return Status  Page Should Contain Element  jquery=div.award-list-wrapper .panel-heading:eq(0) a[data-toggle="collapse"]
  Run Keyword If   'awards[0].complaintPeriod.endDate' == '${arguments[2]}' and ${RESULT}  JsOpenAwardByIndex  0
  Run Keyword And Return If   'awards[0].complaintPeriod.endDate' == '${arguments[2]}' and ${RESULT}   Get text date by locator  jquery=div.award-list-wrapper .panel-collapse.collapse.in p.complaint-period span.end-date
  ${Result}=  Run Keyword And Return Status  Page Should Contain Element  jquery=#tender-contract-form .js-award-complaint-period-wrapper span.end-date  
  Run Keyword And Return If   'awards[0].complaintPeriod.endDate' == '${arguments[2]}' and ${RESULT}   Get text date by locator  jquery=#tender-contract-form .js-award-complaint-period-wrapper span.end-date
# nego viewer
  Run Keyword And Return If   'cause' == '${arguments[2]}'   Get invisible text by locator  jquery=div.tender-info-wrapper p.cause-source
  Run Keyword And Return If   'causeDescription' == '${arguments[2]}'   Get text by locator  jquery=div.tender-info-wrapper p.cause-description span.value  
  Run Keyword And Return If   'procuringEntity.address.countryName' == '${arguments[2]}'   Get invisible text by locator  jquery=div#procuringentityinfo p.country
  Run Keyword And Return If   'procuringEntity.address.postalCode' == '${arguments[2]}'   Get invisible text by locator  jquery=div#procuringentityinfo p.postalcode
  Run Keyword And Return If   'procuringEntity.identifier.scheme' == '${arguments[2]}'   Get invisible text by locator  jquery=div#procuringentityinfo p.identifier-scheme
  Run Keyword If   'documents[0].title' == '${arguments[2]}'   JsOpenDocumentByIndex  0
  Run Keyword And Return If   'documents[0].title' == '${arguments[2]}'   Get invisible text by locator  jquery=#documents .panel-collapse.in .document-info-wrapper p.title
  Run Keyword If   'awards[0].documents[0].title' == '${arguments[2]}'   JsOpenAwardByIndex  0
  Run Keyword And Return If   'awards[0].documents[0].title' == '${arguments[2]}'   Get text by locator  jquery=.award-list-wrapper .panel-collapse.in .award-info-wrapper p.documents + ul.value li:eq(0) a
  Run Keyword If   'awards[0].status' == '${arguments[2]}'   JsOpenAwardByIndex  0
  Run Keyword And Return If   'awards[0].status' == '${arguments[2]}'   Get invisible text by locator  jquery=.award-list-wrapper .panel-collapse.in .award-info-wrapper p.status-source
  Run Keyword If   'awards[0].suppliers[0].address.countryName' == '${arguments[2]}'   JsOpenAwardByIndex  0
  Run Keyword And Return If   'awards[0].suppliers[0].address.countryName' == '${arguments[2]}'   Get invisible text by locator  jquery=.award-list-wrapper .panel-collapse.in .award-info-wrapper p.organization-country
  Run Keyword If   'awards[0].suppliers[0].address.locality' == '${arguments[2]}'   JsOpenAwardByIndex  0
  Run Keyword And Return If   'awards[0].suppliers[0].address.locality' == '${arguments[2]}'   Get invisible text by locator  jquery=.award-list-wrapper .panel-collapse.in .award-info-wrapper p.organization-locality
  Run Keyword If   'awards[0].suppliers[0].address.postalCode' == '${arguments[2]}'   JsOpenAwardByIndex  0
  Run Keyword And Return If   'awards[0].suppliers[0].address.postalCode' == '${arguments[2]}'   Get invisible text by locator  jquery=.award-list-wrapper .panel-collapse.in .award-info-wrapper p.organization-postcode
  Run Keyword If   'awards[0].suppliers[0].address.region' == '${arguments[2]}'   JsOpenAwardByIndex  0
  Run Keyword And Return If   'awards[0].suppliers[0].address.region' == '${arguments[2]}'   Get invisible text by locator  jquery=.award-list-wrapper .panel-collapse.in .award-info-wrapper p.organization-region
  Run Keyword If   'awards[0].suppliers[0].address.streetAddress' == '${arguments[2]}'   JsOpenAwardByIndex  0
  Run Keyword And Return If   'awards[0].suppliers[0].address.streetAddress' == '${arguments[2]}'   Get invisible text by locator  jquery=.award-list-wrapper .panel-collapse.in .award-info-wrapper p.organization-street-address
  Run Keyword If   'awards[0].suppliers[0].contactPoint.telephone' == '${arguments[2]}'   JsOpenAwardByIndex  0
  Run Keyword And Return If   'awards[0].suppliers[0].contactPoint.telephone' == '${arguments[2]}'   Get invisible text by locator  jquery=.award-list-wrapper .panel-collapse.in .award-info-wrapper p.organization-contact-point-phone
  Run Keyword If   'awards[0].suppliers[0].contactPoint.email' == '${arguments[2]}'   JsOpenAwardByIndex  0
  Run Keyword And Return If   'awards[0].suppliers[0].contactPoint.email' == '${arguments[2]}'   Get invisible text by locator  jquery=.award-list-wrapper .panel-collapse.in .award-info-wrapper p.organization-contact-point-email
  Run Keyword If   'awards[0].suppliers[0].identifier.scheme' == '${arguments[2]}'   JsOpenAwardByIndex  0
  Run Keyword And Return If   'awards[0].suppliers[0].identifier.scheme' == '${arguments[2]}'   Get invisible text by locator  jquery=.award-list-wrapper .panel-collapse.in .award-info-wrapper p.organization-scheme
  Run Keyword If   'awards[0].suppliers[0].identifier.legalName' == '${arguments[2]}'   JsOpenAwardByIndex  0
  Run Keyword And Return If   'awards[0].suppliers[0].identifier.legalName' == '${arguments[2]}'   Get invisible text by locator  jquery=.award-list-wrapper .panel-collapse.in .award-info-wrapper p.organization-legal-name
  Run Keyword If   'awards[0].suppliers[0].name' == '${arguments[2]}'   JsOpenAwardByIndex  0
  Run Keyword And Return If   'awards[0].suppliers[0].name' == '${arguments[2]}'   Get invisible text by locator  jquery=.award-list-wrapper .panel-collapse.in .award-info-wrapper p.organization-name
  Run Keyword If   'awards[0].suppliers[0].identifier.id' == '${arguments[2]}'   JsOpenAwardByIndex  0
  Run Keyword And Return If   'awards[0].suppliers[0].identifier.id' == '${arguments[2]}'   Get invisible text by locator  jquery=.award-list-wrapper .panel-collapse.in .award-info-wrapper p.organization-code
  Run Keyword If   'awards[0].value.valueAddedTaxIncluded' == '${arguments[2]}'   JsOpenAwardByIndex  0
  Run Keyword And Return If   'awards[0].value.valueAddedTaxIncluded' == '${arguments[2]}'   Get invisible text boolean by locator  jquery=.award-list-wrapper .panel-collapse.in .award-info-wrapper p.budget-tax-included
  Run Keyword If   'awards[0].value.currency' == '${arguments[2]}'   JsOpenAwardByIndex  0
  Run Keyword And Return If   'awards[0].value.currency' == '${arguments[2]}'   Get invisible text by locator  jquery=.award-list-wrapper .panel-collapse.in .award-info-wrapper p.budget-currency
  Run Keyword If   'awards[0].value.amount' == '${arguments[2]}'   JsOpenAwardByIndex  0
  Run Keyword And Return If   'awards[0].value.amount' == '${arguments[2]}'   Get invisible text number by locator  jquery=.award-list-wrapper .panel-collapse.in .award-info-wrapper p.budget-amount
  Run Keyword If   'awards[0].suppliers[0].contactPoint.name' == '${arguments[2]}'   JsOpenAwardByIndex  0
  Run Keyword And Return If   'awards[0].suppliers[0].contactPoint.name' == '${arguments[2]}'   Get invisible text by locator  jquery=.award-list-wrapper .panel-collapse.in .award-info-wrapper p.organization-contact-point-name
  Run Keyword If   'contracts[0].status' == '${arguments[2]}'   JsOpenContractByIndex  0
  Run Keyword And Return If   'contracts[0].status' == '${arguments[2]}'   Get invisible text by locator  jquery=#accordionContracts .panel-collapse.in .contract-info-wrapper p.status-source
  #
  Run Keyword And Return If  'items[0].description' == '${arguments[2]}'  Get Element Attribute  xpath=//div[contains(@id,'collapseItem')]@data-title

  Fail  Потрібна реалізація в "Отримати інформацію із тендера"

  [return]  pzo.tender.default

Отримати інформацію із лоту
  [Arguments]  ${username}  @{arguments}
  [Documentation]
  ...      ${arguments[0]} == tender_uaid
  ...      ${arguments[1]} == id
  ...      ${arguments[2]} == fieldname
  Switch browser   ${username}

#  Log To Console  ''
#  Log To Console  Отримати інформацію із лоту
#  Log To Console  ${arguments[1]}
#  Log To Console  ${arguments[2]}

  Collapse Lot  ${arguments[1]}
  Run Keyword And Return If   'title' == '${arguments[2]}'   Отримати інформацію із лоту title  ${arguments[1]}
  Run Keyword And Return If   'value.amount' == '${arguments[2]}'   Отримати інформацію із лоту value.amount  ${arguments[1]}
  Run Keyword And Return If   'minimalStep.amount' == '${arguments[2]}'   Отримати інформацію із лоту minimalStep.amount  ${arguments[1]}
  Run Keyword And Return If   'description' == '${arguments[2]}'   Отримати інформацію із лоту description  ${arguments[1]}
  Run Keyword And Return If   'value.currency' == '${arguments[2]}'   Отримати інформацію із лоту value.currency  ${arguments[1]}
  Run Keyword And Return If   'value.valueAddedTaxIncluded' == '${arguments[2]}'   Отримати інформацію із лоту value.valueAddedTaxIncluded  ${arguments[1]}
  Run Keyword And Return If   'minimalStep.currency' == '${arguments[2]}'   Отримати інформацію із лоту minimalStep.currency  ${arguments[1]}
  Run Keyword And Return If   'minimalStep.valueAddedTaxIncluded' == '${arguments[2]}'   Отримати інформацію із лоту minimalStep.valueAddedTaxIncluded  ${arguments[1]}

  Collapse Lot  ${arguments[1]}
  [return]  pzo.lot.default

Отримати інформацію із предмету
  [Arguments]  ${username}  @{arguments}
  [Documentation]
  ...      ${arguments[0]} == tender_uaid
  ...      ${arguments[1]} == id
  ...      ${arguments[2]} == fieldname
  Switch browser   ${username}

#  Log To Console  ''
#  Log To Console  Отримати інформацію із предмету
#  Log To Console  ${arguments[1]}
#  Log To Console  ${arguments[2]}

# nego viewer
  Run Keyword If   '${MODE}' == 'negotiation' and 'description' == '${arguments[2]}'   JsOpenItemByContainsText  ${arguments[1]}
  Run Keyword And Return If   '${MODE}' == 'negotiation' and 'description' == '${arguments[2]}'   Get text by locator  jquery=.panel-lot-collapse.in .panel-item-collapse.in .item-info-wrapper p.title span.value
  Run Keyword If   '${MODE}' == 'negotiation' and 'classification.scheme' == '${arguments[2]}'   JsOpenItemByContainsText  ${arguments[1]}
  Run Keyword And Return If   '${MODE}' == 'negotiation' and 'classification.scheme' == '${arguments[2]}'   Get invisible text by locator  jquery=.panel-lot-collapse.in .panel-item-collapse.in .item-info-wrapper p.main-classification-scheme
  Run Keyword If   '${MODE}' == 'negotiation' and 'classification.id' == '${arguments[2]}'   JsOpenItemByContainsText  ${arguments[1]}
  Run Keyword And Return If   '${MODE}' == 'negotiation' and 'classification.id' == '${arguments[2]}'   Get invisible text by locator  jquery=.panel-lot-collapse.in .panel-item-collapse.in .item-info-wrapper p.main-classification-code
  Run Keyword If   '${MODE}' == 'negotiation' and 'classification.description' == '${arguments[2]}'   JsOpenItemByContainsText  ${arguments[1]}
  Run Keyword And Return If   '${MODE}' == 'negotiation' and 'classification.description' == '${arguments[2]}'   Get invisible text by locator  jquery=.panel-lot-collapse.in .panel-item-collapse.in .item-info-wrapper p.main-classification-description
  Run Keyword If   '${MODE}' == 'negotiation' and 'additionalClassifications[0].scheme' == '${arguments[2]}'   JsOpenItemByContainsText  ${arguments[1]}
  Run Keyword And Return If   '${MODE}' == 'negotiation' and 'additionalClassifications[0].scheme' == '${arguments[2]}'   Get invisible text by locator  jquery=.panel-lot-collapse.in .panel-item-collapse.in .item-info-wrapper p.additional-classification-scheme
  Run Keyword If   '${MODE}' == 'negotiation' and 'additionalClassifications[0].id' == '${arguments[2]}'   JsOpenItemByContainsText  ${arguments[1]}
  Run Keyword And Return If   '${MODE}' == 'negotiation' and 'additionalClassifications[0].id' == '${arguments[2]}'   Get invisible text by locator  jquery=.panel-lot-collapse.in .panel-item-collapse.in .item-info-wrapper p.additional-classification-code
  Run Keyword If   '${MODE}' == 'negotiation' and 'additionalClassifications[0].description' == '${arguments[2]}'   JsOpenItemByContainsText  ${arguments[1]}
  Run Keyword And Return If   '${MODE}' == 'negotiation' and 'additionalClassifications[0].description' == '${arguments[2]}'   Get invisible text by locator  jquery=.panel-lot-collapse.in .panel-item-collapse.in .item-info-wrapper p.additional-classification-description
  Run Keyword If   '${MODE}' == 'negotiation' and 'quantity' == '${arguments[2]}'   JsOpenItemByContainsText  ${arguments[1]}
  Run Keyword And Return If   '${MODE}' == 'negotiation' and 'quantity' == '${arguments[2]}'   Get invisible text number by locator  jquery=.panel-lot-collapse.in .panel-item-collapse.in .item-info-wrapper p.quantity-source
  Run Keyword If   '${MODE}' == 'negotiation' and 'unit.name' == '${arguments[2]}'   JsOpenItemByContainsText  ${arguments[1]}
  Run Keyword And Return If   '${MODE}' == 'negotiation' and 'unit.name' == '${arguments[2]}'   Get invisible text by locator  jquery=.panel-lot-collapse.in .panel-item-collapse.in .item-info-wrapper p.unit-title-source
  Run Keyword If   '${MODE}' == 'negotiation' and 'unit.code' == '${arguments[2]}'   JsOpenItemByContainsText  ${arguments[1]}
  Run Keyword And Return If   '${MODE}' == 'negotiation' and 'unit.code' == '${arguments[2]}'   Get invisible text by locator  jquery=.panel-lot-collapse.in .panel-item-collapse.in .item-info-wrapper p.unit-code-source
  Run Keyword If   '${MODE}' == 'negotiation' and 'deliveryDate.endDate' == '${arguments[2]}'   JsOpenItemByContainsText  ${arguments[1]}
  Run Keyword And Return If   '${MODE}' == 'negotiation' and 'deliveryDate.endDate' == '${arguments[2]}'   Get invisible text by locator  jquery=.panel-lot-collapse.in .panel-item-collapse.in .item-info-wrapper p.delivery-end-date
  Run Keyword If   '${MODE}' == 'negotiation' and 'deliveryAddress.countryName' == '${arguments[2]}'   JsOpenItemByContainsText  ${arguments[1]}
  Run Keyword And Return If   '${MODE}' == 'negotiation' and 'deliveryAddress.countryName' == '${arguments[2]}'   Get invisible text by locator  jquery=.panel-lot-collapse.in .panel-item-collapse.in .item-info-wrapper p.delivery-country
  Run Keyword If   '${MODE}' == 'negotiation' and 'deliveryAddress.postalCode' == '${arguments[2]}'   JsOpenItemByContainsText  ${arguments[1]}
  Run Keyword And Return If   '${MODE}' == 'negotiation' and 'deliveryAddress.postalCode' == '${arguments[2]}'   Get invisible text by locator  jquery=.panel-lot-collapse.in .panel-item-collapse.in .item-info-wrapper p.delivery-postalcode
  Run Keyword If   '${MODE}' == 'negotiation' and 'deliveryAddress.region' == '${arguments[2]}'   JsOpenItemByContainsText  ${arguments[1]}
  Run Keyword And Return If   '${MODE}' == 'negotiation' and 'deliveryAddress.region' == '${arguments[2]}'   Get invisible text by locator  jquery=.panel-lot-collapse.in .panel-item-collapse.in .item-info-wrapper p.delivery-region
  Run Keyword If   '${MODE}' == 'negotiation' and 'deliveryAddress.locality' == '${arguments[2]}'   JsOpenItemByContainsText  ${arguments[1]}
  Run Keyword And Return If   '${MODE}' == 'negotiation' and 'deliveryAddress.locality' == '${arguments[2]}'   Get invisible text by locator  jquery=.panel-lot-collapse.in .panel-item-collapse.in .item-info-wrapper p.delivery-locality
  Run Keyword If   '${MODE}' == 'negotiation' and 'deliveryAddress.streetAddress' == '${arguments[2]}'   JsOpenItemByContainsText  ${arguments[1]}
  Run Keyword And Return If   '${MODE}' == 'negotiation' and 'deliveryAddress.streetAddress' == '${arguments[2]}'   Get invisible text by locator  jquery=.panel-lot-collapse.in .panel-item-collapse.in .item-info-wrapper p.delivery-street-address
  Run Keyword If   '${MODE}' == 'negotiation' and 'deliveryLocation.latitude' == '${arguments[2]}'   JsOpenItemByContainsText  ${arguments[1]}
  Run Keyword And Return If   '${MODE}' == 'negotiation' and 'deliveryLocation.latitude' == '${arguments[2]}'   Get invisible text number by locator  jquery=.panel-lot-collapse.in .panel-item-collapse.in .item-info-wrapper p.delivery-latitude
  Run Keyword If   '${MODE}' == 'negotiation' and 'deliveryLocation.longitude' == '${arguments[2]}'   JsOpenItemByContainsText  ${arguments[1]}
  Run Keyword And Return If   '${MODE}' == 'negotiation' and 'deliveryLocation.longitude' == '${arguments[2]}'   Get invisible text number by locator  jquery=.panel-lot-collapse.in .panel-item-collapse.in .item-info-wrapper p.delivery-longitude

  Run Keyword And Return If   'deliveryLocation.longitude' == '${arguments[2]}'   Fail  Не реалізований функціонал
  Run Keyword And Return If   'deliveryLocation.latitude' == '${arguments[2]}'   Fail  Не реалізований функціонал

  Collapse Single Lot
  Collapse Product  ${arguments[1]}
  Run Keyword And Return If   'description' == '${arguments[2]}'   Отримати інформацію із предмету description  ${arguments[1]}
  Run Keyword And Return If   'deliveryDate.startDate' == '${arguments[2]}'   Отримати інформацію із предмету deliveryDate.startDate  ${arguments[1]}
  Run Keyword And Return If   'deliveryDate.endDate' == '${arguments[2]}'   Отримати інформацію із предмету deliveryDate.endDate  ${arguments[1]}
  Run Keyword And Return If   'deliveryAddress.countryName' == '${arguments[2]}'   Отримати інформацію із предмету deliveryAddress.countryName  ${arguments[1]}
  Run Keyword And Return If   'deliveryAddress.postalCode' == '${arguments[2]}'   Отримати інформацію із предмету deliveryAddress.postalCode  ${arguments[1]}
  Run Keyword And Return If   'deliveryAddress.region' == '${arguments[2]}'   Отримати інформацію із предмету deliveryAddress.region  ${arguments[1]}
  Run Keyword And Return If   'deliveryAddress.locality' == '${arguments[2]}'   Отримати інформацію із предмету deliveryAddress.locality  ${arguments[1]}
  Run Keyword And Return If   'deliveryAddress.streetAddress' == '${arguments[2]}'   Отримати інформацію із предмету deliveryAddress.streetAddress  ${arguments[1]}
  Run Keyword And Return If   'classification.scheme' == '${arguments[2]}'   Отримати інформацію із предмету classification.scheme  ${arguments[1]}
  Run Keyword And Return If   'classification.id' == '${arguments[2]}'   Отримати інформацію із предмету classification.id  ${arguments[1]}
  Run Keyword And Return If   'classification.description' == '${arguments[2]}'   Отримати інформацію із предмету classification.description  ${arguments[1]}
  Run Keyword And Return If   'additionalClassifications[0].scheme' == '${arguments[2]}'   Отримати інформацію із предмету additionalClassifications[0].scheme  ${arguments[1]}
  Run Keyword And Return If   'additionalClassifications[0].id' == '${arguments[2]}'   Отримати інформацію із предмету additionalClassifications[0].id  ${arguments[1]}
  Run Keyword And Return If   'additionalClassifications[0].description' == '${arguments[2]}'   Отримати інформацію із предмету additionalClassifications[0].description  ${arguments[1]}
  Run Keyword And Return If   'unit.name' == '${arguments[2]}'   Отримати інформацію із предмету unit.name  ${arguments[1]}
  Run Keyword And Return If   'unit.code' == '${arguments[2]}'   Отримати інформацію із предмету unit.code  ${arguments[1]}
  Run Keyword And Return If   'quantity' == '${arguments[2]}'   Отримати інформацію із предмету quantity  ${arguments[1]}

  Collapse Product  ${arguments[1]}
  Collapse Single Lot
  [return]  pzo.product.default

Отримати інформацію із нецінового показника
  [Arguments]  ${username}  @{arguments}
  [Documentation]
  ...      ${arguments[0]} == tender_uaid
  ...      ${arguments[1]} == id
  ...      ${arguments[2]} == fieldname
  Switch browser   ${username}

#  Log To Console  ''
#  Log To Console  Отримати інформацію із нецінового показника
#  Log To Console  ${arguments[1]}
#  Log To Console  ${arguments[2]}

  Collapse Feature  ${arguments[1]}
  Run Keyword And Return If   'title' == '${arguments[2]}'   Отримати інформацію із нецінового показника title  ${arguments[1]}
  Run Keyword And Return If   'description' == '${arguments[2]}'   Отримати інформацію із нецінового показника description  ${arguments[1]}
  Run Keyword And Return If   'featureOf' == '${arguments[2]}'   Отримати інформацію із нецінового показника featureOf  ${arguments[1]}

  Collapse Feature  ${arguments[1]}
  [return]  pzo.feature.default

Отримати інформацію із документа
  [Arguments]  ${username}  @{arguments}
  [Documentation]
  ...      ${arguments[0]} == tender_uaid
  ...      ${arguments[1]} == id
  ...      ${arguments[2]} == fieldname
  Switch browser   ${username}

#  Log To Console  ''
#  Log To Console  Отримати інформацію із документа
#  Log To Console  ${arguments[1]}
#  Log To Console  ${arguments[2]}

  Collapse Document  ${arguments[1]}
  Run Keyword And Return If   'title' == '${arguments[2]}'   Отримати інформацію із документа title  ${arguments[1]}

  Collapse Document  ${arguments[1]}
  [return]  pzo.document.default

Отримати інформацію із запитання
  [Arguments]  ${username}  ${tender_uaid}  ${object_id}  ${field_name}
  Switch browser   ${username}

#  Log To Console  ''
#  Log To Console  Отримати інформацію із запитання
#  Log To Console  ${object_id}
#  Log To Console  ${field_name}

  Open Tender
  Switch To Questions

  Collapse Question  ${object_id}
  Run Keyword And Return If   'title' == '${field_name}'   Отримати інформацію із запитання title  ${object_id}
  Run Keyword And Return If   'answer' == '${field_name}'   Отримати інформацію із запитання answer  ${object_id}
  Run Keyword And Return If   'description' == '${field_name}'   Отримати інформацію із запитання description  ${object_id}

  Collapse Question  ${object_id}
  [return]  pzo.question.default

Отримати інформацію із скарги
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${field_name}  ${award_index}
  Switch browser   ${username}

#  Log To Console  ''
#  Log To Console  Отримати інформацію із скарги
#  Log To Console  ${complaintID}
#  Log To Console  ${field_name}
#  Log To Console  ${award_index}

  Open Tender
  Switch To Complaints

  Run Keyword If   'None' != '${complaintID}'  Collapse Complaint  ${complaintID}
  Run Keyword If   'None' == '${complaintID}'  Collapse Single Complaint
  Run Keyword And Return If   'description' == '${field_name}'   Отримати інформацію із скарги description  ${complaintID}
  Run Keyword And Return If   'complaintID' == '${field_name}'   Отримати інформацію із скарги complaintID  ${complaintID}
  Run Keyword And Return If   'title' == '${field_name}'   Отримати інформацію із скарги title  ${complaintID}
  Run Keyword And Return If   'status' == '${field_name}'   Отримати інформацію із скарги status  ${complaintID}
  Run Keyword And Return If   'resolutionType' == '${field_name}'   Отримати інформацію із скарги resolutionType  ${complaintID}
  Run Keyword And Return If   'resolution' == '${field_name}'   Отримати інформацію із скарги resolution  ${complaintID}
  Run Keyword And Return If   'satisfied' == '${field_name}'   Отримати інформацію із скарги satisfied  ${complaintID}
  Run Keyword And Return If   'relatedLot' == '${field_name}'   Отримати інформацію із скарги relatedLot  ${complaintID}
  Run Keyword And Return If   'cancellationReason' == '${field_name}'   Отримати інформацію із скарги cancellationReason  ${complaintID}

  Run Keyword If   'None' != '${complaintID}'  Collapse Complaint  ${complaintID}
  Run Keyword If   'None' == '${complaintID}'  Collapse Single Complaint
  [return]  pzo.complain.default

Отримати інформацію із документа до скарги
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${field_name}  ${award_index}
  Switch browser   ${username}

#  Log To Console  ''
#  Log To Console  Отримати інформацію із документа до скарги
#  Log To Console  ${complaintID}
#  Log To Console  ${field_name}
#  Log To Console  ${award_index}

  Open Tender
  Switch To Complaints

  Run Keyword If   'None' != '${complaintID}'  Collapse Complaint  ${complaintID}
  Run Keyword If   'None' == '${complaintID}'  Collapse Single Complaint
  Run Keyword And Return If   'title' == '${award_index}'   Отримати інформацію із документа до скарги title  ${complaintID}  ${field_name}

  Run Keyword If   'None' != '${complaintID}'  Collapse Complaint  ${complaintID}
  Run Keyword If   'None' == '${complaintID}'  Collapse Single Complaint
  [return]  pzo.complain.document.default

Отримати документ
  [Arguments]  ${username}  ${tender_uaid}  ${doc_id}
  Switch browser   ${username}
  Collapse Document  ${doc_id}
  ${file_link}=  Get Element Attribute  xpath=//div[@id='documents']//div[contains(@data-title,'${doc_id}')]//p[@class='filename']//a[@target='_blank']@href
  ${file_name}=  Convert To String  test_file.txt
  download_file  ${file_link}  ${file_name}  ${OUTPUT_DIR}
  Collapse Document  ${doc_id}
  [return]  ${file_name}

Отримати документ до лоту
  [Arguments]  ${username}  ${tender_uaid}  ${lot_id}  ${doc_id}
  Switch browser   ${username}
  Collapse Lot  ${lot_id}
  Collapse Document2  ${lot_id}  ${doc_id}
  ${file_link}=  Get Element Attribute  xpath=//div[@id='lots']//div[contains(@data-title,'${lot_id}')]//div[contains(@data-title,'${doc_id}')]//p[@class='filename']//a[@target='_blank']@href
  ${file_name}=  Convert To String  test_file_2.txt
  download_file  ${file_link}  ${file_name}  ${OUTPUT_DIR}
  Collapse Document2  ${lot_id}  ${doc_id}
  Collapse Lot  ${lot_id}
  [return]  ${file_name}

Отримати документ до скарги
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${doc_id}
  Switch browser   ${username}

#  Log To Console  ''
#  Log To Console  Отримати документ до скарги
#  Log To Console  ${complaintID}
#  Log To Console  ${doc_id}

  Open Tender
  Switch To Complaints

  Run Keyword If   'None' != '${complaintID}'  Collapse Complaint  ${complaintID}
  Run Keyword If   'None' == '${complaintID}'  Collapse Single Complaint
  ${file_link}=  Get Element Attribute  xpath=//div[@id='tender-complaint-list']//div[@data-complaint-id='${complaintID}']//a[contains(text(),'${doc_id}')]@href
  ${file_name}=  Convert To String  test_file_3.txt
  download_file  ${file_link}  ${file_name}  ${OUTPUT_DIR}

  Run Keyword If   'None' != '${complaintID}'  Collapse Complaint  ${complaintID}
  Run Keyword If   'None' == '${complaintID}'  Collapse Single Complaint
  [return]  ${file_name}

Отримати інформацію із пропозиції
  [Arguments]  ${username}  ${tender_uaid}  ${field}
  Switch browser   ${username}

#  Log To Console  ''
#  Log To Console  Отримати інформацію із пропозиції
#  Log To Console  ${field}

  Open Tender

  Collapse Single Proposal 
  Run Keyword And Return If   'lotValues[0].value.amount' == '${field}'   Отримати інформацію із пропозиції lotValues[0].value.amount
  Run Keyword And Return If   'status' == '${field}'   Отримати інформацію із пропозиції status
  Run Keyword And Return If   'value.amount' == '${field}'   Отримати інформацію із пропозиції lotValues[0].value.amount

  Collapse Single Proposal
  [return]  pzo.proposal.default


# --------------------------------------------------------- #




Collapse Lot
  [Arguments]  ${lot_id}
#  Log To Console  Collapse Lot ${lot_id}
  Click Element    xpath=//div[@id='lots']//span[contains(text(),'${lot_id}')]
  Sleep  1
#  Log To Console  Collapse Lot ${lot_id}

Collapse Single Lot
#  Log To Console  Collapse Single Lot +
  Click Element    xpath=//div[@id='lots']//a[contains(@href,'#collapseLot')]
  Sleep  1
#  Log To Console  Collapse Single Lot +

Collapse Product
  [Arguments]  ${product_id}
#  Log To Console  Collapse Product ${product_id}
  Click Element    xpath=//div[@id='lots']//a[contains(@href,'#collapseItem')]//span[contains(text(),'${product_id}')]
  Sleep  1
#  Log To Console  Collapse Product ${product_id}

Collapse Feature
  [Arguments]  ${feature_id}
#  Log To Console  Collapse Feature ${feature_id}
  Click Element   xpath=//div[@id='features']//span[contains(text(),'${feature_id}')]
  Sleep  1
#  Log To Console  Collapse Feature ${feature_id}

Collapse Document
  [Arguments]  ${document_id}
#  Log To Console  Collapse Document ${document_id}
  Click Element   xpath=//div[@id='documents']//span[contains(text(),'${document_id}')]
  Sleep  1
#  Log To Console  Collapse Document ${document_id}

Collapse Document2
  [Arguments]  ${lot_id}  ${document_id}
#  Log To Console  Collapse Document ${lot_id} ${document_id}
  Click Element   xpath=//div[@id='lots']//div[contains(@data-title,'${lot_id}')]//span[contains(text(),'${document_id}')]
  Sleep  1
#  Log To Console  Collapse Document ${lot_id} ${document_id}

Collapse Question
  [Arguments]  ${question_id}
#  Log To Console  Collapse Question ${question_id}
  Click Element   xpath=//div[@id='tender-question-list']//span[contains(text(),'${question_id}')]
  Sleep  1
#  Log To Console  Collapse Question ${question_id}

Collapse Complaint
  [Arguments]  ${complaint_id}
#  Log To Console  Collapse Complaint ${complaint_id}
  Click Element   xpath=//div[@id='tender-complaint-list']//a[@data-complaint-id='${complaint_id}']
  Sleep  1
#  Log To Console  Collapse Complaint ${complaint_id}

Collapse Single Complaint
#  Log To Console  Collapse Single Complaint +
  Click Element   xpath=//div[@id='tender-complaint-list']//a[contains(@href,'#collapseComplaint')]
  Sleep  1
#  Log To Console  Collapse Single Complaint +

Collapse Single Proposal
#  Log To Console  Collapse Single Proposal +
  Click Element    xpath=//div[@id='myBid']//a[contains(@href,'#collapseMyBid')]
  Sleep  1
#  Log To Console  Collapse Single Proposal +

JsOpenItemByContainsText
  [Arguments]  ${text}
  Execute JavaScript  robottesthelpfunctions.showitembytext('${text}');
  Sleep  3  
  Wait Until Page Contains Element  jquery=.panel-lot-collapse.in .panel-item-collapse.in .item-info-wrapper  10

JsOpenItemByIndex
  [Arguments]  ${index}
  JsOpenItemByContainsText  ${USERS.users['${username}'].tender_data.data.items[${index}].description}

JsOpenDocumentByIndex
  [Arguments]  ${index}
  Execute JavaScript  robottesthelpfunctions.showdocumentbyindex(${index});
  Sleep  3  
  Wait Until Page Contains Element  jquery=#documents .panel-collapse.in .document-info-wrapper  10

JsOpenAwardByIndex
  [Arguments]  ${index}
  Execute JavaScript  robottesthelpfunctions.showawardbyindex(${index});
  Sleep  3  
  Wait Until Page Contains Element  jquery=.award-list-wrapper .panel-collapse.in .award-info-wrapper  10

JsOpenContractByIndex
  [Arguments]  ${index}
  Execute JavaScript  robottesthelpfunctions.showcontractbyindex(${index});
  Sleep  3  
  Wait Until Page Contains Element  jquery=#accordionContracts .panel-collapse.in .contract-info-wrapper  10

# --------------------------------------------------------- #

Get text by locator
  [Arguments]  ${locator}
  ${return_value}=  get_text  ${locator}
  [return]  ${return_value}

Get invisible text by locator
  [Arguments]  ${locator}
  ${return_value}=  get_invisible_text  ${locator}
  [return]  ${return_value}

Get text date by locator
  [Arguments]  ${locator}
  ${return_value}=  get_text  ${locator}
  ${return_value}=  convert_date_for_compare_ex2  ${return_value}
  [return]  ${return_value}

Get invisible text number by locator
  [Arguments]  ${locator}
  ${return_value}=  get_invisible_text  ${locator}
  ${return_value}=  Convert To Number  ${return_value}
  [return]  ${return_value}

Get invisible text boolean by locator
  [Arguments]  ${locator}
  ${return_value}=  get_invisible_text  ${locator}
  ${return_value}=  Run Keyword If  '1' == '${return_value}'  Set Variable  True
    ...  ELSE Set Variable  False
  ${return_value}=  Convert To Boolean  ${return_value}
  [return]  ${return_value}

Отримати інформацію із предмету description
  [Arguments]  ${product_id}
  ${return_value}=  get_text  xpath=//div[@id='lots']//a[contains(@href,'#collapseItem')]//span[contains(text(),'${product_id}')]
  Collapse Product  ${product_id}
  Collapse Single Lot
  [return]  ${return_value}

Отримати інформацію із лоту title
  [Arguments]  ${lot_id}
  ${return_value}=  get_text  xpath=//div[@id='lots']//span[contains(text(),'${lot_id}')]
  Collapse Lot  ${lot_id}
  [return]  ${return_value}

Отримати інформацію із лоту value.amount
  [Arguments]  ${lot_id}
  ${return_value}=  get_text  xpath=//div[@id='lots']//div[contains(@data-title,'${lot_id}')]//p[@class='budget']//span[@class='value']
  ${return_value}=  Evaluate  ''.join('${return_value}'.split()[:-3])
  ${return_value}=  Convert To Number  ${return_value}
  Collapse Lot  ${lot_id}
  [return]  ${return_value}

Отримати інформацію із лоту minimalStep.amount
  [Arguments]  ${lot_id}
  ${return_value}=  get_text  xpath=//div[@id='lots']//div[contains(@data-title,'${lot_id}')]//p[@class='minimal-step']//span[@class='value']
  ${return_value}=  Evaluate  ''.join('${return_value}'.split()[:-3])
  ${return_value}=  Convert To Number  ${return_value}
  Collapse Lot  ${lot_id}
  [return]  ${return_value}

Отримати інформацію із нецінового показника title
  [Arguments]  ${feature_id}
  ${return_value}=  get_text  xpath=//div[@id='features']//span[contains(text(),'${feature_id}')]
  Collapse Feature  ${feature_id}
  [return]  ${return_value}

Отримати інформацію із предмету deliveryDate.startDate
  [Arguments]  ${product_id}
  ${return_value}=  get_invisible_text  //div[@id='lots']//div[contains(@id,'accordionItems')]//div[contains(@data-title,'${product_id}')]//p[@class='delivery-start-date hidden']
  ${return_value}=  convert_date_for_compare_ex  ${return_value}
  Collapse Product  ${product_id}
  Collapse Single Lot
  [return]  ${return_value}

Отримати інформацію із предмету deliveryDate.endDate
  [Arguments]  ${product_id}
  ${return_value}=  get_invisible_text  //div[@id='lots']//div[contains(@id,'accordionItems')]//div[contains(@data-title,'${product_id}')]//p[@class='delivery-end-date hidden']
  ${return_value}=  convert_date_for_compare_ex  ${return_value}
  Collapse Product  ${product_id}
  Collapse Single Lot
  [return]  ${return_value}

Отримати інформацію із предмету deliveryAddress.countryName
  [Arguments]  ${product_id}
  ${return_value}=  get_text  //div[@id='lots']//div[contains(@id,'accordionItems')]//div[contains(@data-title,'${product_id}')]//p[@class='delivery']//span[@class='country']
  Collapse Product  ${product_id}
  Collapse Single Lot
  [return]  ${return_value}

Отримати інформацію із предмету deliveryAddress.postalCode
  [Arguments]  ${product_id}
  ${return_value}=  get_text  //div[@id='lots']//div[contains(@id,'accordionItems')]//div[contains(@data-title,'${product_id}')]//p[@class='delivery']//span[@class='postcode']
  Collapse Product  ${product_id}
  Collapse Single Lot
  [return]  ${return_value}

Отримати інформацію із предмету deliveryAddress.region
  [Arguments]  ${product_id}
  ${return_value}=  get_text  //div[@id='lots']//div[contains(@id,'accordionItems')]//div[contains(@data-title,'${product_id}')]//p[@class='delivery']//span[@class='region']
  Collapse Product  ${product_id}
  Collapse Single Lot
  [return]  ${return_value}

Отримати інформацію із предмету deliveryAddress.locality
  [Arguments]  ${product_id}
  ${return_value}=  get_text  //div[@id='lots']//div[contains(@id,'accordionItems')]//div[contains(@data-title,'${product_id}')]//p[@class='delivery']//span[@class='locality']
  Collapse Product  ${product_id}
  Collapse Single Lot
  [return]  ${return_value}

Отримати інформацію із предмету deliveryAddress.streetAddress
  [Arguments]  ${product_id}
  ${return_value}=  get_text  //div[@id='lots']//div[contains(@id,'accordionItems')]//div[contains(@data-title,'${product_id}')]//p[@class='delivery']//span[@class='street-address']
  Collapse Product  ${product_id}
  Collapse Single Lot
  [return]  ${return_value}

Отримати інформацію із предмету classification.scheme
  [Arguments]  ${product_id}
  Collapse Product  ${product_id}
  Collapse Single Lot
  [return]  CPV

Отримати інформацію із предмету classification.id
  [Arguments]  ${product_id}
  ${return_value}=  get_text  //div[@id='lots']//div[contains(@id,'accordionItems')]//div[contains(@data-title,'${product_id}')]//p[@class='classification'][1]//span[@class='value']
  ${return_value}=  Split String  ${return_value}  max_split=1
  Collapse Product  ${product_id}
  Collapse Single Lot
  [return]  ${return_value[0]}

Отримати інформацію із предмету classification.description
  [Arguments]  ${product_id}
  ${return_value}=  get_text  //div[@id='lots']//div[contains(@id,'accordionItems')]//div[contains(@data-title,'${product_id}')]//p[@class='classification'][1]//span[@class='value']
  ${return_value}=  Split String  ${return_value}  max_split=1
  Collapse Product  ${product_id}
  Collapse Single Lot
  [return]  ${return_value[1]}

Отримати інформацію із предмету additionalClassifications[0].scheme
  [Arguments]  ${product_id}
  ${return_value}=  get_invisible_text  //div[@id='lots']//div[contains(@id,'accordionItems')]//div[contains(@data-title,'${product_id}')]//p[@class='additional-classification-scheme hidden']
  Collapse Product  ${product_id}
  Collapse Single Lot
  [return]  ${return_value}

Отримати інформацію із предмету additionalClassifications[0].id
  [Arguments]  ${product_id}
  ${return_value}=  get_text  //div[@id='lots']//div[contains(@id,'accordionItems')]//div[contains(@data-title,'${product_id}')]//p[@class='classification'][2]//span[@class='value']
  ${return_value}=  Split String  ${return_value}  max_split=1
  Collapse Product  ${product_id}
  Collapse Single Lot
  [return]  ${return_value[0]}

Отримати інформацію із предмету additionalClassifications[0].description
  [Arguments]  ${product_id}
  ${return_value}=  get_text  //div[@id='lots']//div[contains(@id,'accordionItems')]//div[contains(@data-title,'${product_id}')]//p[@class='classification'][2]//span[@class='value']
  ${return_value}=  Split String  ${return_value}  max_split=1
  Collapse Product  ${product_id}
  Collapse Single Lot
  [return]  ${return_value[1]}

Отримати інформацію із предмету unit.name
  [Arguments]  ${product_id}
  ${return_value}=  get_text  //div[@id='lots']//div[contains(@id,'accordionItems')]//div[contains(@data-title,'${product_id}')]//p[@class='quantity']//span[@class='value']
  ${return_value}=  Split String  ${return_value}  max_split=1
  Collapse Product  ${product_id}
  Collapse Single Lot
  [return]  ${return_value[1]}

Отримати інформацію із предмету unit.code
  [Arguments]  ${product_id}
  ${return_value}=  get_invisible_text  //div[@id='lots']//div[contains(@id,'accordionItems')]//div[contains(@data-title,'${product_id}')]//p[@class='unit-code-source hidden']
  Collapse Product  ${product_id}
  Collapse Single Lot
  [return]  ${return_value}

Отримати інформацію із предмету quantity
  [Arguments]  ${product_id}
  ${return_value}=  get_text  //div[@id='lots']//div[contains(@id,'accordionItems')]//div[contains(@data-title,'${product_id}')]//p[@class='quantity']//span[@class='value']
  ${return_value}=  Split String  ${return_value}  max_split=1
  ${return_value}=  Convert To Number  ${return_value[0]}
  Collapse Product  ${product_id}
  Collapse Single Lot
  [return]  ${return_value}

Отримати інформацію із лоту description
  [Arguments]  ${lot_id}
  ${return_value}=  get_text  xpath=//div[@id='lots']//div[contains(@data-title,'${lot_id}')]//p[@class='description']
  Collapse Lot  ${lot_id}
  [return]  ${return_value}

Отримати інформацію із лоту value.currency
  [Arguments]  ${lot_id}
  ${summa}=  get_text  xpath=//div[@id='lots']//div[contains(@data-title,'${lot_id}')]//p[@class='budget']//span[@class='value']
  Collapse Lot  ${lot_id}
  Run Keyword And Return If  'UAH' in '${summa}'  Convert To String  UAH
  Run Keyword And Return If  'RUB' in '${summa}'  Convert To String  RUB
  Run Keyword And Return If  'USD' in '${summa}'  Convert To String  USD
  Run Keyword And Return If  'EUR' in '${summa}'  Convert To String  EUR
  Run Keyword And Return If  'GBP' in '${summa}'  Convert To String  GBP
  [return]  ${EMPTY}

Отримати інформацію із лоту value.valueAddedTaxIncluded
  [Arguments]  ${lot_id}
  ${return_value}=  get_text  xpath=//div[@id='lots']//div[contains(@data-title,'${lot_id}')]//p[@class='budget']//span[@class='value']
  ${return_value}=  Run Keyword If  'ПДВ' in '${return_value}'  Set Variable  True
    ...  ELSE Set Variable  False
  ${return_value}=  Convert To Boolean  ${return_value}
  Collapse Lot  ${lot_id}
  [return]  ${return_value}

Отримати інформацію із лоту minimalStep.currency
  [Arguments]  ${lot_id}
  ${summa}=  get_text  xpath=//div[@id='lots']//div[contains(@data-title,'${lot_id}')]//p[@class='minimal-step']//span[@class='value']
  Collapse Lot  ${lot_id}
  Run Keyword And Return If  'UAH' in '${summa}'  Convert To String  UAH
  Run Keyword And Return If  'RUB' in '${summa}'  Convert To String  RUB
  Run Keyword And Return If  'USD' in '${summa}'  Convert To String  USD
  Run Keyword And Return If  'EUR' in '${summa}'  Convert To String  EUR
  Run Keyword And Return If  'GBP' in '${summa}'  Convert To String  GBP
  [return]  ${EMPTY}

Отримати інформацію із лоту minimalStep.valueAddedTaxIncluded
  [Arguments]  ${lot_id}
  ${return_value}=  get_text  xpath=//div[@id='lots']//div[contains(@data-title,'${lot_id}')]//p[@class='minimal-step']//span[@class='value']
  ${return_value}=  Run Keyword If  'ПДВ' in '${return_value}'  Set Variable  True
    ...  ELSE Set Variable  False
  ${return_value}=  Convert To Boolean  ${return_value}
  Collapse Lot  ${lot_id}
  [return]  ${return_value}

Отримати інформацію із нецінового показника description
  [Arguments]  ${feature_id}
  ${return_value}=  get_text  xpath=//div[@id='features']//div[contains(@data-title,'${feature_id}')]//p[@class='description']
  Collapse Feature  ${feature_id}
  [return]  ${return_value}

Отримати інформацію із нецінового показника featureOf
  [Arguments]  ${feature_id}
  ${return_value}=  get_text  xpath=//div[@id='features']//div[contains(@data-title,'${feature_id}')]//p[@class='related-item']//span[@class='value']
  Collapse Feature  ${feature_id}
  Run Keyword And Return If  'Лот' in '${return_value}'  Convert To String  lot
  Run Keyword And Return If  'Учасник закупівлі' in '${return_value}'  Convert To String  tenderer
  Run Keyword And Return If  'Товар/послуга' in '${return_value}'  Convert To String  item
  [return]  pzo.feature.default

Отримати інформацію із документа title
  [Arguments]  ${document_id}
  ${return_value}=  get_text  xpath=//div[@id='documents']//span[contains(text(),'${document_id}')]
  Collapse Document  ${document_id}
  [return]  ${return_value}

Отримати інформацію із запитання title
  [Arguments]  ${question_id}
  ${return_value}=  get_text  xpath=//div[@id='tender-question-list']//span[contains(text(),'${question_id}')]
  Collapse Question  ${question_id}
  [return]  ${return_value}

Отримати інформацію із запитання answer
  [Arguments]  ${question_id}
  ${return_value}=  get_text  xpath=//div[@id='tender-question-list']//div[contains(@data-title,'${question_id}')]//p[@class='answer']//span[@class='value']
  Collapse Question  ${question_id}
  [return]  ${return_value}

Отримати інформацію із запитання description
  [Arguments]  ${question_id}
  ${return_value}=  get_text  xpath=//div[@id='tender-question-list']//div[contains(@data-title,'${question_id}')]//p[@class='description']//span[@class='value']
  Collapse Question  ${question_id}
  [return]  ${return_value}

Switch To Complaints
  Click Element                      xpath=//a[contains(@href, '/tender/complaints?id=')]
  Wait Until Page Contains           Вимоги/скарги   10

Отримати інформацію із скарги description
  [Arguments]  ${complaint_id}
  Capture Page Screenshot
  ${return_value}=  get_text  xpath=//div[@id='tender-complaint-list']//div[@data-complaint-id='${complaint_id}']//p[@class='description']//span[@class='value']
  Run Keyword If  'None' != '${complaint_id}'  Collapse Complaint  ${complaint_id}
  Run Keyword If  'None' == '${complaint_id}'  Collapse Single Complaint
  [return]  ${return_value}

Отримати інформацію із скарги complaintID
  [Arguments]  ${complaint_id}
  Run Keyword If  'None' != '${complaint_id}'  Collapse Complaint  ${complaint_id}
  Run Keyword If  'None' == '${complaint_id}'  Collapse Single Complaint
  [return]  ${complaint_id}

Отримати інформацію із скарги title
  [Arguments]  ${complaint_id}
  Capture Page Screenshot
  ${return_value}=  get_text  xpath=//div[@id='tender-complaint-list']//div[@data-complaint-id='${complaint_id}']//p[@class='title']//span[@class='value']
  Run Keyword If  'None' != '${complaint_id}'  Collapse Complaint  ${complaint_id}
  Run Keyword If  'None' == '${complaint_id}'  Collapse Single Complaint
  [return]  ${return_value}

Отримати інформацію із скарги status
  [Arguments]  ${complaint_id}
  ${return_value}=  get_invisible_text  xpath=//div[@id='tender-complaint-list']//div[@data-complaint-id='${complaint_id}']//p[@class='status-source hidden']
  Run Keyword If  'None' != '${complaint_id}'  Collapse Complaint  ${complaint_id}
  Run Keyword If  'None' == '${complaint_id}'  Collapse Single Complaint
  [return]  ${return_value}

Отримати інформацію із скарги resolutionType
  [Arguments]  ${complaint_id}
  ${return_value}=  get_invisible_text  xpath=//div[@id='tender-complaint-list']//div[@data-complaint-id='${complaint_id}']//p[@class='resolution-type-source hidden']
  Run Keyword If  'None' != '${complaint_id}'  Collapse Complaint  ${complaint_id}
  Run Keyword If  'None' == '${complaint_id}'  Collapse Single Complaint
  [return]  ${return_value}

Отримати інформацію із скарги resolution
  [Arguments]  ${complaint_id}
  Capture Page Screenshot
  ${return_value}=  get_text  xpath=//div[@id='tender-complaint-list']//div[@data-complaint-id='${complaint_id}']//p[@class='resolution']//span[@class='value']
  Run Keyword If  'None' != '${complaint_id}'  Collapse Complaint  ${complaint_id}
  Run Keyword If  'None' == '${complaint_id}'  Collapse Single Complaint
  [return]  ${return_value}

Отримати інформацію із скарги satisfied
  [Arguments]  ${complaint_id}
  ${return_value}=  get_invisible_text  xpath=//div[@id='tender-complaint-list']//div[@data-complaint-id='${complaint_id}']//p[@class='satisfied-source hidden']
  ${return_value}=  Run Keyword If  '1' == '${return_value}'  Set Variable  True
    ...  ELSE Set Variable  False
  ${return_value}=  Convert To Boolean  ${return_value}
  Run Keyword If  'None' != '${complaint_id}'  Collapse Complaint  ${complaint_id}
  Run Keyword If  'None' == '${complaint_id}'  Collapse Single Complaint
  [return]  ${return_value}

Отримати інформацію із документа до скарги title
  [Arguments]  ${complaint_id}  ${document_id}
  ${return_value}=  get_text  xpath=//div[@id='tender-complaint-list']//div[@data-complaint-id='${complaint_id}']//a[contains(text(),'${document_id}')]
  Run Keyword If  'None' != '${complaint_id}'  Collapse Complaint  ${complaint_id}
  Run Keyword If  'None' == '${complaint_id}'  Collapse Single Complaint
  [return]  ${return_value}

Отримати інформацію про qualificationPeriod.endDate
  [return]  pzo.test

Отримати інформацію із тендера tenderPeriod.startDate
  ${return_value}=  get_text  xpath=//p[contains(@class, 'tender-period')]//*[@class='value']//span[contains(@class, 'start-date')]
  ${return_value}=  convert_date_for_compare_ex   ${return_value}
  [return]  ${return_value}

Отримати інформацію із тендера tenderPeriod.endDate
  ${return_value}=  get_text  xpath=//p[contains(@class, 'tender-period')]//*[@class='value']//span[contains(@class, 'end-date')]
  ${return_value}=  convert_date_for_compare_ex   ${return_value}
  [return]  ${return_value}

Отримати інформацію із тендера procurementMethodType
  ${return_value}=  get_invisible_text  xpath=//*[contains(@class, 'hidden opprocurementmethodtype')]
  [return]  ${return_value}

Отримати інформацію із тендера value.amount
  ${return_value}=  get_text  xpath=//p[contains(@class, 'budget')]//*[@class='value']
  ${return_value}=  Evaluate  ''.join('${return_value}'.split()[:-3])
  ${return_value}=  Convert To Number  ${return_value}
  [return]  ${return_value}

Отримати інформацію із тендера status
  Open Tender
  ${return_value}=   get_invisible_text  xpath=//*[contains(@class, 'hidden opstatus')]
  [return]  ${return_value}

Отримати інформацію із тендера enquiryPeriod.startDate
  ${return_value}=  get_text  xpath=//p[contains(@class, 'enquiry-period')]//*[@class='value']//span[contains(@class, 'start-date')]
  ${return_value}=  convert_date_for_compare_ex   ${return_value}
  [return]  ${return_value}

Отримати інформацію із тендера enquiryPeriod.endDate
  ${return_value}=  get_text  xpath=//p[contains(@class, 'enquiry-period')]//*[@class='value']//span[contains(@class, 'end-date')]
  ${return_value}=  convert_date_for_compare_ex   ${return_value}
  [return]  ${return_value}

Отримати інформацію із тендера complaintPeriod.startDate
  ${return_value}=  get_text  xpath=//p[contains(@class, 'complaint-period')]//*[@class='value']//span[contains(@class, 'start-date')]
  ${return_value}=  convert_date_for_compare_ex   ${return_value}
  [return]  ${return_value}

Отримати інформацію із тендера complaintPeriod.endDate
  ${return_value}=  get_text  xpath=//p[contains(@class, 'complaint-period')]//*[@class='value']//span[contains(@class, 'end-date')]
  ${return_value}=  convert_date_for_compare_ex   ${return_value}
  [return]  ${return_value}

Отримати інформацію із тендера title
  ${return_value}=  get_text  xpath=//p[contains(@class, 'title')]//*[@class='value']
  #'Run Keyword And Return If' workaround if browser width is less than ours
  Run Keyword And Return If  '${return_value}' == '${EMPTY}'  get_text  xpath=//h4[contains(@class, 'page-title')]
  [return]  ${return_value}

Отримати інформацію із тендера description
  ${return_value}=  get_text  xpath=//p[@class='description']
  [return]  ${return_value}

Отримати інформацію із тендера value.currency
  ${summa}=  get_text  xpath=//p[contains(@class, 'budget')]//*[@class='value']
  Run Keyword And Return If  'UAH' in '${summa}'  Convert To String  UAH
  Run Keyword And Return If  'RUB' in '${summa}'  Convert To String  RUB
  Run Keyword And Return If  'USD' in '${summa}'  Convert To String  USD
  Run Keyword And Return If  'EUR' in '${summa}'  Convert To String  EUR
  Run Keyword And Return If  'GBP' in '${summa}'  Convert To String  GBP
  [return]  ${EMPTY}

Отримати інформацію із тендера value.valueAddedTaxIncluded
  ${return_value}=  get_text  xpath=//p[contains(@class, 'budget')]//*[@class='value']
  ${return_value}=  Run Keyword If  'ПДВ' in '${return_value}'  Set Variable  True
    ...  ELSE Set Variable  False
  ${return_value}=  Convert To Boolean  ${return_value}
  [return]  ${return_value}

Отримати інформацію із тендера tenderID
  ${return_value}=  get_text  xpath=//*[contains(@class, 'tender-id')]//*[@class='value']
  [return]  ${return_value}

Отримати інформацію із тендера procuringEntity.name
  ${return_value}=  get_text  xpath=//*[contains(@class, 'legal-name')]//*[@class='value']
  [return]  ${return_value}

Отримати інформацію із тендера minimalStep.amount
  Collapse Single Lot
  ${return_value}=  get_text  xpath=//div[@id='lots']//p[@class='minimal-step']//span[@class='value']
  ${return_value}=  Evaluate  ''.join('${return_value}'.split()[:-3])
  ${return_value}=  Convert To Number  ${return_value}
  Collapse Single Lot
  [return]  ${return_value}

Отримати інформацію із пропозиції lotValues[0].value.amount
  ${return_value}=  get_text  xpath=//div[@id='myBid']//div[contains(@id,'collapseMyBid')]//p[contains(@class, 'budget')]//*[@class='value']
  ${return_value}=  Evaluate  ''.join('${return_value}'.split()[:-3])
  ${return_value}=  Convert To Number  ${return_value}
  Collapse Single Proposal
  [return]  ${return_value}

Отримати інформацію із пропозиції status
  ${return_value}=  get_invisible_text  xpath=//div[@id='myBid']//div[contains(@id,'collapseMyBid')]//p[contains(@class, 'status-source hidden')]
  Collapse Single Proposal
  [return]  ${return_value}

Отримати інформацію із тендера qualifications[0].status
  Click Element  jquery=div#accordionQualifications div.panel:eq(0) a[data-toggle="collapse"]
  ${return_value}=  get_invisible_text  jquery=div#accordionQualifications div.panel:eq(0) p.status-source
  Click Element  jquery=div#accordionQualifications div.panel:eq(0) a[data-toggle="collapse"]
  [return]  ${return_value}

Отримати інформацію із тендера qualifications[1].status
  Click Element  jquery=div#accordionQualifications div.panel:eq(1) a[data-toggle="collapse"]
  ${return_value}=  get_invisible_text  jquery=div#accordionQualifications div.panel:eq(1) p.status-source
  Click Element  jquery=div#accordionQualifications div.panel:eq(1) a[data-toggle="collapse"]
  [return]  ${return_value}

Отримати інформацію із тендера qualificationPeriod.endDate
  ${return_value}=  get_text  xpath=//p[contains(@class, 'prequalification-period')]//*[@class='value']//span[contains(@class, 'end-date')]
  ${return_value}=  convert_date_for_compare_ex   ${return_value}
  [return]  ${return_value}

Отримати інформацію із скарги cancellationReason
  [Arguments]  ${complaint_id}
  ${return_value}=  get_text  xpath=//div[@id='tender-complaint-list']//div[@data-complaint-id='${complaint_id}']//p[@class='cancellation-reason']//span[@class='value']
  Run Keyword If  'None' != '${complaint_id}'  Collapse Complaint  ${complaint_id}
  Run Keyword If  'None' == '${complaint_id}'  Collapse Single Complaint
  [return]  ${return_value}

Отримати інформацію із скарги relatedLot
  [Arguments]  ${complaint_id}
  ${return_value}=  get_invisible_text  xpath=//div[@id='tender-complaint-list']//div[@data-complaint-id='${complaint_id}']//p[@class='related-item-source hidden']
  Run Keyword If  'None' != '${complaint_id}'  Collapse Complaint  ${complaint_id}
  Run Keyword If  'None' == '${complaint_id}'  Collapse Single Complaint
  [return]  ${return_value}


