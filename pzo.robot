*** Settings ***
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
${tender_page_prefix}=                                         ${BROKERS['pzo'].basepage}/tender/view?id=
${tender_sync_prefix}=                                         ${BROKERS['pzo'].basepage}/utils/tender-sync?pk=
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
  inject_urllib3
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
  ${procurementMethodType} =  Set Variable If  'procurementMethodType' in ${tender_data_keys}  ${tender_data.data.procurementMethodType}  belowThreshold
  Set To Dictionary  ${USERS.users['${PZO_LOGIN_USER}']}  tender_methodtype=${procurementMethodType}

  # change organization info
  #UserChangeOrgnizationInfo  ${tender_data.data.procuringEntity}

#  Run Keyword If  '${SUITE_NAME}' == 'Tests Files.Complaints'  Go To  ${BROKERS['pzo'].basepage}/utils/config?tacceleration=${BROKERS['pzo'].intervals.belowThreshold.accelerator}
  Run Keyword If  '${SUITE_NAME}' == 'Tests Files.Complaints' and '${procurementMethodType}' == 'belowThreshold'  Go To  ${BROKERS['pzo'].basepage}/utils/config?tacceleration=360
  Run Keyword If  '${procurementMethodType}' == 'negotiation'  Go To  ${BROKERS['pzo'].basepage}/utils/config?tacceleration=1080
  Run Keyword If  '${procurementMethodType}' == 'aboveThresholdUA.defense'  Go To  ${BROKERS['playtender'].basepage}/utils/config?tacceleration=720

  Selenium2Library.Switch Browser    ${user}
  Run Keyword If  '${procurementMethodType}' == 'belowThreshold' and 'lots' not in ${tender_data_keys}  Go To  ${BROKERS['pzo'].basepage}/tender/create?type=${procurementMethodType}&multilot=0
  Run Keyword If  '${procurementMethodType}' != 'belowThreshold' or 'lots' in ${tender_data_keys}  Go To  ${BROKERS['pzo'].basepage}/tender/create?type=${procurementMethodType}
  Wait Until Page Contains          Створення закупівлі  10

  ### BOF - Reporting ###
  Run Keyword And Return If  '${procurementMethodType}' == 'reporting'  Створити тендер без лотів  ${user}  ${tender_data}
  Run Keyword And Return If  '${procurementMethodType}' == 'belowThreshold' and 'lots' not in ${tender_data_keys}  Створити тендер без лотів  ${user}  ${tender_data}
  ### EOF - Reporting ###

  ${title}=         Get From Dictionary   ${tender_data.data}               title
  ${description}=   Get From Dictionary   ${tender_data.data}               description
  ${pzo_proc_type}=  Convert_to_Lowercase  ${procurementMethodType}
  ${pzo_proc_type}=  Remove String  ${pzo_proc_type}  \.

  Input text  id=tender${pzo_proc_type}form-title  ${title}
  Run Keyword If  'cause' in ${tender_data_keys}  Select From List By Value  id=tender${pzo_proc_type}form-cause  ${tender_data.data.cause}
  Run Keyword If  'causeDescription' in ${tender_data_keys}  Input text  id=tender${pzo_proc_type}form-cause_description  ${tender_data.data.causeDescription}
  Run Keyword If  'title_en' in ${tender_data_keys}  Input Text With Checking Input Isset  \#tender${pzo_proc_type}form-title_en  ${tender_data.data.title_en}
  Input text  id=tender${pzo_proc_type}form-description  ${description}
  Run Keyword If  'description_en' in ${tender_data_keys}  Input Text With Checking Input Isset  \#tender${pzo_proc_type}form-description_en  ${tender_data.data.description_en}
  Run Keyword If  'fundingKind' in ${tender_data_keys}  Select From List By Value  id=tender${pzo_proc_type}form-funding_kind  ${tender_data.data.fundingKind}
  Run Keyword If  'NBUdiscountRate' in ${tender_data_keys}  Input Float Multiply100  \#tender${pzo_proc_type}form-nbu_discount_rate  ${tender_data.data.NBUdiscountRate}
  Click Element  id=tender${pzo_proc_type}form-value_added_tax_included
  Run Keyword If  'mainProcurementCategory' in ${tender_data_keys}  Select From List By Value  id=tender${pzo_proc_type}form-main_procurement_category  ${tender_data.data.mainProcurementCategory}
  Run Keyword If  '${procurementMethodType}' == 'belowThreshold'  Створити тендер enquiryPeriod.startDate  ${pzo_proc_type}  ${tender_data.data.enquiryPeriod.startDate}
  Run Keyword If  '${procurementMethodType}' == 'belowThreshold'  Створити тендер enquiryPeriod.endDate  ${pzo_proc_type}  ${tender_data.data.enquiryPeriod.endDate}
  Run Keyword If  '${procurementMethodType}' == 'belowThreshold'  Створити тендер tenderPeriod.startDate  ${pzo_proc_type}  ${tender_data.data.tenderPeriod.startDate}
  Run Keyword If  '${procurementMethodType}' != 'negotiation'  Створити тендер tenderPeriod.end_date  ${pzo_proc_type}  ${tender_data.data.tenderPeriod.endDate}
  Select Checkbox  id=tender${pzo_proc_type}form-quick_mode
  Run Keyword If  '${SUITE_NAME}' == 'Tests Files.Complaints'  Select Checkbox  id=tender${pzo_proc_type}form-auction_skip_mode

  ### BOF - BelowFunders ###
  Run Keyword If  'funders' in ${tender_data_keys}  Створити тендер Funder  ${tender_data.data.funders[0]}
  ### EOF - BelowFunders ###

  Click Element  xpath=//*[contains(@href, '#collapseLots')]
  Sleep  1
  JsSetScrollToElementBySelector  \#collapseLots
  Click Element  xpath=//span[@data-confirm-text='Ви впевнені що бажаєте видалити поточний лот?']
  Click Element  xpath=//div[contains(@class, 'jconfirm-box')]//button[contains(text(), 'Так')]

  ${items}=         Get From Dictionary   ${tender_data.data}               items
  ${lots}=          Get From Dictionary   ${tender_data.data}               lots
  Set To Dictionary  ${USERS.users['${PZO_LOGIN_USER}']}  lots=${lots}
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

  ${Ids}=  Створити тендер Збереження форми
  [return]  ${Ids}

Створити тендер без лотів
  [Arguments]  ${user}  ${tender_data}
  ${tender_data_keys}=  Get Dictionary Keys  ${tender_data.data}
  ${procurementMethodType}=  Get From Dictionary  ${USERS.users['${PZO_LOGIN_USER}']}  tender_methodtype
  ${budget}=          convert_float_to_string  ${tender_data.data.value.amount}
  ${pzo_proc_type}=  Convert_to_Lowercase  ${procurementMethodType}
  ${pzo_proc_type}=  Remove String  ${pzo_proc_type}  \.

  # fill general data
  Input text  id=tender${pzo_proc_type}form-title  ${tender_data.data.title}
  Input text  id=tender${pzo_proc_type}form-description  ${tender_data.data.description}
  JsSetScrollToElementBySelector  \#tender${pzo_proc_type}form-value_amount
  Input text  id=tender${pzo_proc_type}form-value_amount  ${budget}
  Select From List By Value  id=tender${pzo_proc_type}form-value_currency  ${tender_data.data.value.currency}
  Run Keyword If  ${tender_data.data.value.valueAddedTaxIncluded}  Click Element  id=tender${pzo_proc_type}form-value_added_tax_included
  Run Keyword If  '${procurementMethodType}' == 'belowThreshold'  Input Float  \#tender${pzo_proc_type}form-min_step_amount  ${tender_data.data.minimalStep.amount}
  Run Keyword If  '${procurementMethodType}' == 'belowThreshold'  Створити тендер enquiryPeriod.startDate  ${pzo_proc_type}  ${tender_data.data.enquiryPeriod.startDate}
  Run Keyword If  '${procurementMethodType}' == 'belowThreshold'  Створити тендер enquiryPeriod.endDate  ${pzo_proc_type}  ${tender_data.data.enquiryPeriod.endDate}
  Run Keyword If  '${procurementMethodType}' == 'belowThreshold'  Створити тендер tenderPeriod.startDate  ${pzo_proc_type}  ${tender_data.data.tenderPeriod.startDate}
  Run Keyword If  '${procurementMethodType}' == 'belowThreshold'  Створити тендер tenderPeriod.end_date  ${pzo_proc_type}  ${tender_data.data.tenderPeriod.endDate}
  Run Keyword If  '${procurementMethodType}' == 'belowThreshold'  Select Checkbox  id=tender${pzo_proc_type}form-quick_mode

  # fill items
  Click Element  xpath=//*[contains(@href, '#collapseItems')]
  Sleep  1
  JsSetScrollToElementBySelector  \#collapseItems
  Click Element  xpath=//span[@data-confirm-text='Ви впевнені що бажаєте видалити поточний товар/послугу?']
  Click Element  xpath=//div[contains(@class, 'jconfirm-box')]//button[contains(text(), 'Так')]

  ${items}=         Get From Dictionary   ${tender_data.data}               items
  ${items_length}=  Get Length  ${items}

  : FOR    ${INDEX}    IN RANGE    0    ${items_length}
  \   JsSetScrollToElementBySelector  \#collapseItems a[href='#add-items']
  \   Click Element  jquery=#collapseItems a[href="#add-items"]
  \   Sleep  2
  \   Додати предмет By Wrapper  \#collapseItems div[data-type='item'].active  ${items[${INDEX}]}  ${procurementMethodType}

  Run Keyword If  '${procurementMethodType}' == 'reporting'  Додати постачальника For Reporting Fake

  ${Ids}=  Створити тендер Збереження форми
  [return]  ${Ids}

Створити тендер Збереження форми
  JsSetScrollToElementBySelector  \#submitBtn
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

Створити тендер Funder
  [Arguments]  ${funderData}
  Click Element   id=tenderbelowthresholdform-is_donor
  Click Element   id=tenderbelowthresholdform-funder_organization_id
  Click Element   jquery=#tenderbelowthresholdform-funder_organization_id option[data-identifier-code=${funderData.identifier.id}]

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
  ${pzo_proc_type}=  Remove String  ${pzo_proc_type}  \.
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
  ${pzo_proc_type}=  Remove String  ${pzo_proc_type}  \.
  ${pzo_proc_type}=   Set Variable If  '${pzo_proc_type}' == 'belowthreshold'  ${EMPTY}  ${pzo_proc_type}

  Input text                         xpath=//div[contains(@class, 'active')]//div[contains(@class, 'form-group field-lot${pzo_proc_type}form')]//input[contains(@id, '-title')]  ${arguments[0].title}
  Run Keyword If  'title_en' in ${lot_keys}  Input Text With Checking Input Isset  \#collapseLots .tab-pane.active[data-type='lot'] div[class^='form-group field-lot${pzo_proc_type}form'] input[id$='-title_en']  ${arguments[0].title_en}
  Input text                         xpath=//div[contains(@class, 'active')]//div[contains(@class, 'form-group field-lot${pzo_proc_type}form')]//textarea[contains(@id, '-description')]  ${arguments[0].description}
  Run Keyword If  'description_en' in ${lot_keys}  Input Text With Checking Input Isset  \#collapseLots .tab-pane.active[data-type='lot'] div[class^='form-group field-lot${pzo_proc_type}form'] input[id$='-description_en']  ${arguments[0].description_en}
  Run Keyword If  'minimalStepPercentage' in ${lot_keys}  Input Float Multiply100  \#collapseLots .tab-pane.active[data-type='lot'] div[class^='form-group field-lot${pzo_proc_type}form'] input[id$='-min_step_percentage']  ${arguments[0].minimalStepPercentage}
  Run Keyword If  'yearlyPaymentsPercentageRange' in ${lot_keys}  Input Float Multiply100  \#collapseLots .tab-pane.active[data-type='lot'] div[class^='form-group field-lot${pzo_proc_type}form'] input[id$='-yearly_payments_percentage_range']  ${arguments[0].yearlyPaymentsPercentageRange}
  Run Keyword If  'value' in ${lot_keys}  Input Float  \#collapseLots .tab-pane.active[data-type='lot'] div[class^='form-group field-lot${pzo_proc_type}form'] input[id$='-value_amount']  ${arguments[0].value.amount}
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
  ${pzo_proc_type}=  Remove String  ${pzo_proc_type}  \.
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
  ${pzo_proc_type}=  Remove String  ${pzo_proc_type}  \.
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

  ${pzo_proc_type}=  Convert_to_Lowercase  ${ARGUMENTS[2]}
  ${pzo_proc_type}=  Remove String  ${pzo_proc_type}  \.
  ${pzo_proc_type}=  Set Variable If  '${pzo_proc_type}' == 'belowthreshold'  ${EMPTY}  ${pzo_proc_type}
  ${wraper}=  Convert To String  div[contains(@class, 'form-group lot${pzo_proc_type}form-items-dynamic-forms-wrapper')]
  ${jqueryWrapper}=  Set Variable  \#collapseLots div[data-type='lot'].active div[data-type='item'].active div[class^='form-group field-item${pzo_proc_type}form']

  Input text                         xpath=//div[contains(@class, 'active')]//${wraper}//div[contains(@class, 'active')]//div[contains(@class, 'form-group field-item${pzo_proc_type}form')]//input[contains(@id, '-description')]  ${description}
  Run Keyword If  'description_en' in ${item_keys}
  ...  Input Text With Checking Input Isset  ${jqueryWrapper} input[id$='-description_en']  ${ARGUMENTS[0].description_en}
  Input Text With Checking Input Isset XPath  div[contains(@class, 'active')]//${wraper}//div[contains(@class, 'active')]//div[contains(@class, 'form-group field-item${pzo_proc_type}form')]//input[contains(@id, '-quantity')]  ${quantity}
  Select From List By Label With Checking Input Isset XPath          div[contains(@class, 'active')]//${wraper}//div[contains(@class, 'active')]//div[contains(@class, 'form-group field-item${pzo_proc_type}form')]//select[contains(@id, '-unit_id')]  ${unit}

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
  Run Keyword If  'additionalClassifications' in ${item_keys}  Sleep  1

  Run Keyword If  '${ARGUMENTS[2]}' == 'belowThreshold'  Click Element  xpath=//div[contains(@class, 'active')]//${wraper}//div[contains(@class, 'active')]//input[contains(@id, '-delivery')]

  Select From List By Label          //div[contains(@class, 'active')]//${wraper}//div[contains(@class, 'active')]//div[contains(@class, 'form-group field-item${pzo_proc_type}form')]//select[contains(@id, '-delivery_region_id')]  ${region}
  Sleep  1
  Input Text                        xpath=//div[contains(@class, 'active')]//${wraper}//div[contains(@class, 'active')]//div[contains(@class, 'form-group field-item${pzo_proc_type}form')]//input[contains(@id, '-delivery_locality')]  ${locality}
  Input Text                        xpath=//div[contains(@class, 'active')]//${wraper}//div[contains(@class, 'active')]//div[contains(@class, 'form-group field-item${pzo_proc_type}form')]//input[contains(@id, '-delivery_street_address')]  ${street}
  Input Text                        xpath=//div[contains(@class, 'active')]//${wraper}//div[contains(@class, 'active')]//div[contains(@class, 'form-group field-item${pzo_proc_type}form')]//input[contains(@id, '-delivery_postal_code')]  ${code}
  Run Keyword If  'deliveryDate' in ${item_keys}  Input DateTime XPath  div[contains(@class, 'active')]//${wraper}//div[contains(@class, 'active')]//div[contains(@class, 'form-group field-item${pzo_proc_type}form')]//input[contains(@id, '-delivery_start_date')]  ${ARGUMENTS[0].deliveryDate.startDate}
  Run Keyword If  'deliveryDate' in ${item_keys}  Input DateTime XPath  div[contains(@class, 'active')]//${wraper}//div[contains(@class, 'active')]//div[contains(@class, 'form-group field-item${pzo_proc_type}form')]//input[contains(@id, '-delivery_end_date')]  ${ARGUMENTS[0].deliveryDate.endDate}

  Run Keyword If  'deliveryLocation' in ${item_keys}
  ...  InputItemDeliveryLocationByWrapper  \#collapseLots div[data-type='lot'].active div[data-type='item'].active  ${ARGUMENTS[0].deliveryLocation}  ${ARGUMENTS[2]}

Додати предмет By Wrapper
  [Arguments]  ${wrapper}  ${data}  ${procurementMethodType}
  ${data_keys}=  Get Dictionary Keys  ${data}
  ${quantity_srt}=  Convert To String  ${data.quantity}
  ${pzo_proc_type}=  GetInputProcTypeByProcurementMethodType  ${procurementMethodType}

  JsSetScrollToElementBySelector  ${wrapper} div[class^='form-group field-item${pzo_proc_type}form'] input[id$='-description']
  Input text  jquery=${wrapper} div[class^='form-group field-item${pzo_proc_type}form'] input[id$='-description']  ${data.description}
  Run Keyword If  'description_en' in ${data_keys}  Input Text With Checking Input Isset  ${wrapper} div[class^='form-group field-item${pzo_proc_type}form'] input[id$='-description_en']  ${data.description_en}
  JsSetScrollToElementBySelector  ${wrapper} div[class^='form-group field-item${pzo_proc_type}form'] input[id$='-quantity']
  Input text  jquery=${wrapper} div[class^='form-group field-item${pzo_proc_type}form'] input[id$='-quantity']  ${quantity_srt}
  Select From List By Label  jquery=${wrapper} div[class^='form-group field-item${pzo_proc_type}form'] select[id$='-unit_id']  ${data.unit.name}
  InputClassificationByWrapper  ${wrapper}  ${data.classification.id}
  Run Keyword If  'additionalClassifications' in ${data_keys}
  ...  InputAdditionalClassificationsByWrapper  ${wrapper}  ${data.additionalClassifications}
  Run Keyword If  'deliveryAddress' in ${data_keys}
  ...  InputItemDeliveryAddressByWrapper  ${wrapper}  ${data.deliveryAddress}  ${procurementMethodType}
  Run Keyword If  'deliveryDate' in ${data_keys}
  ...  InputItemDeliveryDateByWrapper  ${wrapper}  ${data.deliveryDate}  ${procurementMethodType}
  Run Keyword If  'deliveryLocation' in ${data_keys}
  ...  InputItemDeliveryLocationByWrapper  ${wrapper}  ${data.deliveryLocation}  ${procurementMethodType}

InputItemDeliveryAddressByWrapper
  [Arguments]  ${wrapper}  ${data}  ${procurementMethodType}
  ${pzo_proc_type}=  GetInputProcTypeByProcurementMethodType  ${procurementMethodType}

  JsSetScrollToElementBySelector  ${wrapper} div[class^='form-group field-item${pzo_proc_type}form'] input[id$='-delivery_region_id']
  Select From List By Label  jquery=${wrapper} div[class^='form-group field-item${pzo_proc_type}form'] select[id$='-delivery_region_id']  ${data.region}
  Input text  jquery=${wrapper} div[class^='form-group field-item${pzo_proc_type}form'] input[id$='-delivery_postal_code']  ${data.postalCode}
  Input text  jquery=${wrapper} div[class^='form-group field-item${pzo_proc_type}form'] input[id$='-delivery_locality']  ${data.locality}
  Input text  jquery=${wrapper} div[class^='form-group field-item${pzo_proc_type}form'] input[id$='-delivery_street_address']  ${data.streetAddress}

InputItemDeliveryLocationByWrapper
  [Arguments]  ${wrapper}  ${data}  ${procurementMethodType}

  run keyword and ignore error  Execute JavaScript  jQuery("${wrapper} input[id$='-delivery_location_latitude']").val("${data.latitude}");
  run keyword and ignore error  Execute JavaScript  jQuery("${wrapper} input[id$='-delivery_location_longitude']").val("${data.longitude}");

InputItemDeliveryDateByWrapper
  [Arguments]  ${wrapper}  ${data}  ${procurementMethodType}
  ${data_keys}=  Get Dictionary Keys  ${data}
  ${pzo_proc_type}=  GetInputProcTypeByProcurementMethodType  ${procurementMethodType}

  JsSetScrollToElementBySelector  ${wrapper} div[class^='form-group field-item${pzo_proc_type}form'] input[id$='-delivery_start_date']
  Run Keyword If  'startDate' in ${data_keys}
  ...  Input DateTime  ${wrapper} div[class^='form-group field-item${pzo_proc_type}form'] input[id$='-delivery_start_date']  ${data.startDate}
  Run Keyword If  'endDate' in ${data_keys}
  ...  Input DateTime  ${wrapper} div[class^='form-group field-item${pzo_proc_type}form'] input[id$='-delivery_end_date']  ${data.endDate}

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
  \   Continue For Loop If  '${ARGUMENTS[0][${INDEX}].scheme}' == 'ДКПП'
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

  ${feature_keys}=  Get Dictionary Keys  ${arguments[0]}
  ${featureOf}=  Set Variable If  '${arguments[4]}' == 'tenderer'  ${EMPTY}  ${arguments[4]}
  ${pzo_proc_type}=  Convert_to_Lowercase  ${arguments[2]}
  ${pzo_proc_type}=  Remove String  ${pzo_proc_type}  \.
  ${pzo_proc_type}=  Set Variable If  '${pzo_proc_type}' == 'belowthreshold'  ${EMPTY}  ${pzo_proc_type}
  ${pzo_proc_type}=  Set Variable If  '${pzo_proc_type}' == 'abovethresholdua'  ${EMPTY}  ${pzo_proc_type}
  ${wraper}=  Set Variable If  '${pzo_proc_type}' == ''  form-group field-${featureOf}featureform  form-group field-feature${pzo_proc_type}form
  ${wraper2}=  Set Variable If  '${pzo_proc_type}' == ''  form-group ${featureOf}featureform-enums-dynamic-forms-wrapper  form-group feature${pzo_proc_type}form-enums-dynamic-forms-wrapper
  ${options}=  Get From Dictionary  ${arguments[0]}  enum

  Input text                         xpath=//${arguments[3]}//div[contains(@class, 'active')]//div[contains(@class, '${wraper}')]//input[contains(@id, '-title')]  ${arguments[0].title}
  Run Keyword If  'title_en' in ${feature_keys}
    ...  Input Text With Checking Input Isset XPath  ${arguments[3]}//div[contains(@class, 'active')]//div[contains(@class, '${wraper}')]//input[contains(@id, '-title_en')]  ${arguments[0].title_en}
  Input text                         xpath=//${arguments[3]}//div[contains(@class, 'active')]//div[contains(@class, '${wraper}')]//input[contains(@id, '-description')]  ${arguments[0].description}
  Run Keyword If  'description_en' in ${feature_keys}
      ...  Input Text With Checking Input Isset XPath  ${arguments[3]}//div[contains(@class, 'active')]//div[contains(@class, '${wraper}')]//input[contains(@id, '-description_en')]  ${arguments[0].description_en}

  ${options_length}=  Get Length  ${options}

  : FOR    ${INDEX}    IN RANGE    0    ${options_length}
  \   Click Element  xpath=//${arguments[3]}//div[contains(@class, 'active')]//a[@href='#add-enums']
  \   Sleep  2
  \   Input text  xpath=//${arguments[3]}//div[contains(@class, 'active')]//div[contains(@class, '${wraper2}')]//div[contains(@class, 'active')]//input[contains(@id, '-title')]  ${options[${INDEX}].title}
  \   Input Text With Checking Input Isset XPath  ${arguments[3]}//div[contains(@class, 'active')]//div[contains(@class, '${wraper2}')]//div[contains(@class, 'active')]//input[contains(@id, '-title_en')]  ${options[${INDEX}].title}
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

  Go To  ${BROKERS['pzo'].basepage}/utils/tender-sync?tenderid=${ARGUMENTS[1]}
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
  Sleep  3
  ${count}=  execute javascript    return $('#tender-list .js-item').length;
  ${count}=  convert to integer  ${count}
  run keyword if  ${count} == 1  Click Element    xpath=(//div[@id='tender-list'])//a[contains(@href, '/tender/')][1]
  run keyword if  ${count} > 1  Click Element    jquery=#tender-list .js-item:nth(1) a.title.js-link
  Wait Until Page Contains    ${ARGUMENTS[1]}   60
  Save Tender ID
  Capture Page Screenshot

Пошук тендера за кошти донора
  [Arguments]  ${username}  @{arguments}
  ${identifier}=  Set Variable  ${arguments[0]}

  Go To  ${BROKERS['pzo'].basepage}/tenders?funder_organization=${identifier}
  Wait Until Page Contains Element    id=tender-list    30
  Capture Page Screenshot  tender_with_funders_search_result
  Sleep  5

  # redirect to tender view for getting data
  Go To  ${BROKERS['pzo'].basepage}/tender/${TENDER.TENDER_UAID}
  Wait Until Page Contains    ${TENDER.TENDER_UAID}    10

Завантажити документ
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${filepath}
  ...      ${ARGUMENTS[2]} ==  ${TENDER_UAID}
  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
  Open Tender
  Wait Until Page Contains  Ідентифікатор закупівлі  20
  Click Element  xpath=//a[contains(@href, '/tender/update?id=')]
  Sleep  1
  wait until page contains element    id=tender-form    10

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
  Sleep  3
  Reload Page
  Page Should Not Contain Element  id=tender-sync-info

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
  wait until page contains element    id=tender-form    10

  ### BOF - Reporting ###
  ${procurementMethodType}=  Get From Dictionary  ${USERS.users['${PZO_LOGIN_USER}']}  tender_methodtype
  Run Keyword If  '${procurementMethodType}' == 'reporting'  Додати постачальника For Reporting  ${ARGUMENTS[2].data.value.amount}  ${ARGUMENTS[2].data.suppliers[0]}
  ### EOF - Reporting ###

  Run Keyword If  '${procurementMethodType}' != 'reporting'  Click Element   xpath=//*[@class='panel-heading']//*[@href='#collapseAward']
  Run Keyword If  '${procurementMethodType}' != 'reporting'  Sleep  1

  Run Keyword If  '${procurementMethodType}' != 'reporting'  Click Element  jquery=div.awards-dynamic-forms-wrapper .nav a.js-dynamic-form-add
  Run Keyword If  '${procurementMethodType}' != 'reporting'  Sleep  2
  Run Keyword If  '${procurementMethodType}' != 'reporting'  Додати постачальника  ${ARGUMENTS[2].data.lotID}  ${ARGUMENTS[2].data}

  Save Tender

  Click Element   jquery=#tender-part-pjax .list-group-item[href*="tender/qualification"]
  Sleep  1
  Wait Until Page Contains  Кваліфікація  10
  Select From List By Value  id=qualificationform-decision  accept

  ### BOF - Reporting ###
  Run Keyword If  '${procurementMethodType}' == 'reporting'  Click Element   jquery=#qualification-documents a.js-dynamic-form-add[href="#add-documents"]
  Run Keyword If  '${procurementMethodType}' == 'reporting'  Sleep  2
  JsSetScrollToElementBySelector  \#qualification-documents
  ### EOF - Reporting ###

  Choose File  jquery=div.documents-dynamic-forms-wrapper div[data-type="awarddocument"].active div.fileupload-input-wrapper input[type="file"]  ${ARGUMENTS[3]}
  Sleep  2
  Wait Until Page Contains Element  jquery=div.documents-dynamic-forms-wrapper div[data-type="awarddocument"].active div.fileupload-input-wrapper div.btn.item  60
  Run Keyword And Ignore Error  Click Element   id=qualificationform-qualified

  Click Element   jquery=#tender-qualification-form .js-submit-btn
  Sleep  1
  Wait Until Page Contains   Рішення завантажене, тепер потрібно накласти ЕЦП.   60
  Click Element   xpath=//div[contains(@class, 'jconfirm-box')]//button[contains(@class, 'btn btn-default waves-effect waves-light btn-lg')]
  Sleep  1

  Click Element   jquery=#tender-qualification-form .js-submit-btn
  Sleep  1
  Load Sign
  Wait Until Page Contains   ЕЦП успішно накладено на рішення, тепер потрібно підтвердити рішення.   20
  Click Element   xpath=//div[contains(@class, 'jconfirm-box')]//button[contains(@class, 'btn btn-default waves-effect waves-light btn-lg')]
  Sleep  1

  Click Element   jquery=#tender-qualification-form .js-submit-btn
  Sleep  1
  Wait Until Page Contains   Рішення підтверджене, очікує опублікування на сайті уповноваженого органу.   20
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

Додати постачальника For Reporting
  [Arguments]  ${budget}  ${data}
  ${wrapper}=  Set Variable  \#collapseAward

  JsSetScrollToElementBySelector  \#collapseAward
  Click Element  jquery=.panel-title a[data-toggle="collapse"][href="#collapseAward"]
  Sleep  2
  JsSetScrollToElementBySelector  ${wrapper} \#tenderreportingform-award_organization_name

  Input Text    jquery=${wrapper} \#tenderreportingform-award_organization_name  ${data.name}
  Input Text    jquery=${wrapper} \#tenderreportingform-award_organization_edrpou  ${data.identifier.id}
  JsSetScrollToElementBySelector  ${wrapper} \#tenderreportingform-award_organization_region_id
  Select From List By Label    jquery=${wrapper} \#tenderreportingform-award_organization_region_id  ${data.address.region}
  Input Text    jquery=${wrapper} \#tenderreportingform-award_organization_postal_code  ${data.address.postalCode}
  Input Text    jquery=${wrapper} \#tenderreportingform-award_organization_locality  ${data.address.locality}
  Input Text    jquery=${wrapper} \#tenderreportingform-award_organization_street_address  ${data.address.streetAddress}
  Input Text    jquery=${wrapper} \#tenderreportingform-award_organization_contact_point_name  ${data.contactPoint.name}
  Input Text    jquery=${wrapper} \#tenderreportingform-award_organization_contact_point_email  ${data.contactPoint.email}
  Input Text    jquery=${wrapper} \#tenderreportingform-award_organization_contact_point_phone  ${data.contactPoint.telephone}
  Input Float    ${wrapper} \#tenderreportingform-award_value_amount  ${budget}

Додати постачальника For Reporting Fake
  ${identifier}  Create Dictionary    id=1234567890
  ${address}  Create Dictionary    region=місто Київ  postalCode=123  locality=Київ  streetAddress=address
  ${contactPoint}  Create Dictionary    name=name  email=test@test.ru  telephone=123123
  ${data}    Create Dictionary    name=Organization    identifier=${identifier}  address=${address}  contactPoint=${contactPoint}
  Додати постачальника For Reporting  1  ${data}

Редагувати угоду
  [Arguments]  @{arguments}
  [Documentation]
  ...      ${arguments[0]} =  ${username}
  ...      ${arguments[1]} =  ${tender_uaid}
  ...      ${arguments[2]} =  ${contract_index}
  ${field}=  Set Variable  ${arguments[3]}
  ${value}=  Convert To String  ${arguments[4]}
  ${arguments_length}=  Get Length  ${arguments}

  # open contract form
  Open Tender
  Click Element  xpath=//a[contains(@href, '/tender/contract?id=')]
  Sleep  1
  Wait Until Page Contains  Завантаження контракту  10

  # wait complaint period ended
  JsSetScrollToElementBySelector  .js-award-complaint-period-wrapper
  ${complaint_period_end_date}=  get_invisible_text  jquery=.js-award-complaint-period-wrapper .award-complaint-period-end-date-source.hidden
  Wait date  ${complaint_period_end_date}
  Sleep  60

  Встановити поле відкритої форми редагування угоди  ${field}  ${value}
  Run Keyword If  ${arguments_length} > 6  Встановити поле відкритої форми редагування угоди  ${arguments[5]}  ${arguments[6]}

  ${contract_number}=  Get Value  id=contractform-contract_number
  Run Keyword If  '${contract_number}' == ''  Input Text  id=contractform-contract_number  1234567890
  ${date_signed}=  Get Current Date  result_format=%d.%m.%Y %H:%M
  ${contract_date_signed}=  Get Value  id=contractform-date_signed
  Run Keyword If  '${contract_date_signed}' == ''  Input Text  id=contractform-date_signed  ${date_signed}
  ${date_start}=  Get Current Date  increment=02:00:00  result_format=%d.%m.%Y %H:%M
  ${contract_date_start}=  Get Value  id=contractform-date_start
  Run Keyword If  '${contract_date_start}' == ''  Input Text  id=contractform-date_start  ${date_start}
  ${date_end}=  Get Current Date  increment=04:00:00  result_format=%d.%m.%Y %H:%M
  ${contract_date_end}=  Get Value  id=contractform-date_end
  Run Keyword If  '${contract_date_end}' == ''  Input Text  id=contractform-date_end  ${date_end}
  ${document_isset}=  Run keyword And Return Status  Page Should Contain Element  jquery=.contractform-documents-dynamic-forms-wrapper .js-dynamic-forms-list > .js-item:last .js-fileupload-input-wrapper .init-value,.contractform-documents-dynamic-forms-wrapper .js-dynamic-forms-list > .js-item:last .js-fileupload-input-wrapper .btn.js-item
  Run Keyword If  ${document_isset} == False  Завантажити у відкриту форму редагування угоди документ  Fake

  # click save button
  JsSetScrollToElementBySelector  \#tender-contract-form .js-submit-btn
  Click Element   jquery=\#tender-contract-form .js-submit-btn
  Sleep  1
  Capture Page Screenshot
  Wait Until Page Contains   Контракт успішно завантажений   10
  Click Element   xpath=//div[contains(@class, 'jconfirm-box')]//button[contains(@class, 'btn btn-default waves-effect waves-light btn-lg')]

  # wait sync
  WaitPageSyncing  60

Встановити дату підписання угоди
  [Arguments]  @{arguments}
  [Documentation]
  ...      ${arguments[0]} =  ${username}
  ...      ${arguments[1]} =  ${tender_uaid}
  ...      ${arguments[2]} =  ${contract_index}
  ...      ${arguments[3]} =  ${date_signed}

  pzo.Редагувати угоду  ${arguments[0]}  ${arguments[1]}  ${arguments[2]}  dateSigned  ${arguments[3]}

Вказати період дії угоди
  [Arguments]  @{arguments}
  [Documentation]
  ...      ${arguments[0]} =  ${username}
  ...      ${arguments[1]} =  ${tender_uaid}
  ...      ${arguments[2]} =  ${contract_index}
  ...      ${arguments[3]} =  ${date_start}
  ...      ${arguments[4]} =  ${date_end}

  pzo.Редагувати угоду  ${arguments[0]}  ${arguments[1]}  ${arguments[2]}  period.startDate  ${arguments[3]}  period.endDate  ${arguments[4]}

Завантажити документ в угоду
  [Arguments]  @{arguments}
  [Documentation]
  ...      ${arguments[0]} =  ${username}
  ...      ${arguments[1]} =  ${filename}
  ...      ${arguments[2]} =  ${tender_uaid}
  ...      ${arguments[3]} =  ${contract_index}

  pzo.Редагувати угоду  ${arguments[0]}  ${arguments[2]}  ${arguments[3]}  document  ${arguments[1]}

Підтвердити підписання контракту
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} =  ${username}
  ${procurementMethodType}=  Отримати інформацію із тендера procurementMethodType
  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
  Sleep  61
  Open Tender
  Wait Until Page Contains  Ідентифікатор закупівлі  20
  Click Element  xpath=//a[contains(@href, '/tender/contract?id=')]
  Sleep  1
  Wait Until Page Contains  Завантаження контракту  10
  Перевірити неможливість підписання контракту
  ${contract_number}=  Get Value  id=contractform-contract_number
  Run Keyword If  '${contract_number}' == ''  Input Text  id=contractform-contract_number  1234567890
  ${date_start}=  Get Current Date  increment=02:00:00  result_format=%d.%m.%Y %H:%M
  ${contract_date_start}=  Get Value  id=contractform-date_start
  Run Keyword If  '${contract_date_start}' == ''  Input Text  id=contractform-date_start  ${date_start}
  ${date_end}=  Get Current Date  increment=04:00:00  result_format=%d.%m.%Y %H:%M
  ${contract_date_end}=  Get Value  id=contractform-date_end
  Run Keyword If  '${contract_date_end}' == ''  Input Text  id=contractform-date_end  ${date_end}
  ${document_isset}=  Run keyword And Return Status  Page Should Contain Element  jquery=.contractform-documents-dynamic-forms-wrapper .js-dynamic-forms-list > .js-item:last .js-fileupload-input-wrapper .init-value,.contractform-documents-dynamic-forms-wrapper .js-dynamic-forms-list > .js-item:last .js-fileupload-input-wrapper .btn.js-item
  Run Keyword If  ${document_isset} == False and '${procurementMethodType}' != 'reporting'  Завантажити у відкриту форму редагування угоди документ  Fake

  Click Element   jquery=#tender-contract-form .js-submit-btn
  Sleep  1
  Wait Until Page Contains   Контракт успішно завантажений   20
  Click Element   xpath=//div[contains(@class, 'jconfirm-box')]//button[contains(@class, 'btn btn-default waves-effect waves-light btn-lg')]
  WaitPageSyncing  62

  Wait Until Page Contains   Активувати контракт   20
  Click Element  xpath=//a[contains(@href, '/tender/contract-activate?id=')]
  Sleep  1
  Wait Until Page Contains  Активація контракту  20
  JsSetScrollToElementBySelector  \#tender-contract-form .js-submit-btn
  ${sign_needed}=  Run keyword And Return Status  Page Should Contain  Накласти ЕЦП
  Click Element   jquery=#tender-contract-form .js-submit-btn
  Sleep  1

  Run Keyword If  '${SUITE_NAME}' == 'Tests Files.Negotiation' or ${sign_needed}
  ...  Run Keywords
  ...  Load Sign
  ...  AND
  ...  Wait Until Page Contains   ЕЦП успішно накладено   20
  ...  AND
  ...  Click Element   xpath=//div[contains(@class, 'jconfirm-box')]//button[contains(@class, 'btn btn-default waves-effect waves-light btn-lg')]
  ...  AND
  ...  Sleep  1
  ...  AND
  ...  Click Element   jquery=#tender-contract-form .js-submit-btn
  ...  AND
  ...  Sleep  1

  Wait Until Page Contains   Контракт успішно активовано   20
  Click Element   xpath=//div[contains(@class, 'jconfirm-box')]//button[contains(@class, 'btn btn-default waves-effect waves-light btn-lg')]

  # wait sync
  WaitPageSyncing  300

Перевірити неможливість підписання контракту
  ${date_sign}=  Get Current Date  local  0  %d.%m.%Y %H:%M
  ${contract_date_signed}=  Get Value  id=contractform-date_signed
  Run Keyword If  '${contract_date_signed}' == ''  Input Text  id=contractform-date_signed  ${date_sign}
  Execute JavaScript    $('#contractform-date_signed').blur();
  Sleep  3
  Capture Page Screenshot
  ${status}=  Run keyword And Return Status  Page Should Contain  Значення "Дата підписання" повинно бути більшим значення
  Run Keyword If  ${status}  Fail  Підписати контракт неможливо
  ${status}=  Run keyword And Return Status  Page Should Contain  Контракт можна буде підписати після
  Run Keyword If  ${status}  Fail  Підписати контракт неможливо

Встановити поле відкритої форми редагування угоди
  [Arguments]  ${field}  ${value}

  JsSetScrollToElementBySelector  \#contractform-contract_number
  Run Keyword If  '${field}' == 'value.amount'  Input Float  \#contractform-value_amount  ${value}
  Run Keyword If  '${field}' == 'dateSigned'  Input DateTime  \#contractform-date_signed  ${value}
  Run Keyword If  '${field}' == 'period.startDate'  Input DateTime  \#contractform-date_start  ${value}
  Run Keyword If  '${field}' == 'period.endDate'  Input DateTime  \#contractform-date_end  ${value}
  Run Keyword If  '${field}' == 'document'  Завантажити у відкриту форму редагування угоди документ  ${value}

Завантажити у відкриту форму редагування угоди документ
  [Arguments]  ${filename}

  # resolve filename
  ${filename}=  Run Keyword If  '${filename}' == 'Fake'  GenerateFakeDocument
  ...  ELSE  Set Variable  ${filename}

  JsSetScrollToElementBySelector  \#contractform-documents
  Choose File  jquery=.contractform-documents-dynamic-forms-wrapper .js-dynamic-forms-list .js-item.active .js-fileupload-input-wrapper .js-btn-upload input[type=file]  ${filename}
  Sleep  3

Load Sign
  ${loadingKey}=  Run keyword And Return Status  Wait Until Page Contains   Серійний номер   40
  Run Keyword If  ${loadingKey} == False  Load Sign Data
  Wait Until Page Contains   Серійний номер   60
  Click Element   id=SignDataButton
  Sleep  5

Load Sign Data
  Wait Until Page Contains Element   id=CAsServersSelect   60
  Select From List By Label   id=CAsServersSelect     Тестовий ЦСК АТ "ІІТ"
  Wait Until Page Contains Element  id=PKeyFileInput  10
  Choose File   id=PKeyFileInput     ${CURDIR}/Key-6.dat
  Wait Until Page Contains Element  id=PKeyPassword  10
  Input Text    id=PKeyPassword     12345677
  Wait Until Page Contains Element  id=PKeyReadButton  10
  Click Element   id=PKeyReadButton

Wait user action
  [Arguments]  @{ARGUMENTS}
  Execute JavaScript    alertMsg({content: 'wait user action', autoClose: '299'});
  Wait Until Page Does Not Contain    wait user action  300

Оновити сторінку з тендером
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} =  username
  ...      ${ARGUMENTS[1]} =  ${TENDER_UAID}

  # open for owner without syncing
  Run Keyword And Return If  '${ROLE}' == 'tender_owner'  Go To  ${BROKERS['pzo'].basepage}/tender/${ARGUMENTS[1]}

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
  ${pzo_proc_type}=  Remove String  ${pzo_proc_type}  \.

#  Log To Console  ${ARGUMENTS[0]}
#  Log To Console  ${ARGUMENTS[1]}
#  Log To Console  ${ARGUMENTS[2]}
#  Log To Console  ${ARGUMENTS[3]}

  Click Element  xpath=//a[contains(@href, '/tender/update?id=')]
  Sleep  1
  wait until page contains element    id=tender-form    10

  Run Keyword If  '${ARGUMENTS[2]}' == 'tenderPeriod.endDate'  Внести зміни в тендер tenderPeriod.endDate  ${ARGUMENTS[3]}  ${procurementMethodType}
  Run Keyword If  '${ARGUMENTS[2]}' == 'description'  Input text  id=tender${pzo_proc_type}form-description  ${ARGUMENTS[3]}
  Sleep  1

  Save Tender
  Capture Page Screenshot

Внести зміни в тендер tenderPeriod.endDate
  [Arguments]  ${value}  ${procurementMethodType}
  ${pzo_proc_type}=  Convert_to_Lowercase  ${procurementMethodType}
  ${pzo_proc_type}=  Remove String  ${pzo_proc_type}  \.
  ${converted_date}=  convert_datetime_for_delivery  ${value}
  ${converted_date}=  Convert Date  ${converted_date}  %d.%m.%Y %H:%M
  Input text  id=tender${pzo_proc_type}form-tender_period_end_date  ${converted_date}

Отримати посилання на аукціон для глядача
  [Arguments]  ${username}  @{arguments}
  Selenium2Library.Switch browser  ${username}
  Wait For Status  active.auction  ${username}  100000
  Open Tender
  ${return_value}=   get_invisible_text  xpath=//*[contains(@class, 'hidden auction-url')]
  [return]  ${return_value}

Отримати посилання на аукціон для учасника
  [Arguments]  ${username}  @{arguments}
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
  Wait Until Page Contains Element  id=tender-question-list  10

Save tender ID
  ${status}=  Run keyword And Return Status  Dictionary Should Not Contain Key  ${USERS.users['${PZO_LOGIN_USER}']}  TENDER_ID
  ${procurementMethodType}=  Отримати інформацію із тендера procurementMethodType
  Run Keyword If  ${status} or '${procurementMethodType}' == 'competitiveDialogueUA.stage2' or '${procurementMethodType}' == 'competitiveDialogueEU.stage2'  Add id to tender

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
  Open Tender Without Transfer and Syncing

Open Tender With Syncing
  Sync Tender
  Open Tender Without Transfer and Syncing

Open Tender Without Transfer and Syncing
  ${tender_id}=  Get From Dictionary  ${USERS.users['${PZO_LOGIN_USER}']}  TENDER_ID
  ${tender_url}=  Catenate  SEPARATOR=  ${tender_page_prefix}  ${tender_id}
  Go To  ${tender_url}
  Wait Until Page Contains Element  id=tender-general-info  3

Wait For All Transfer Complete
  ${sync_passed}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  100 s  0 s  Wait For Transfer Complete
  Run Keyword Unless  ${sync_passed}  Fatal Error  Sync not finish in 100 sec

Wait For Transfer Complete
  Sleep  2
  Reload Page
  Run Keyword And Ignore Error  Click Element  xpath=//div[@id='myBid']//a[contains(@href,'#collapseMyBid')]
  Run Keyword If  '${ROLE}' == 'provider'  Sleep  500ms
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
  sleep    1
  wait until page contains element    id=tender-form    10
  Click Element  xpath=//*[contains(@href, '#collapseLots')]
  Sleep  1
  Click Element  xpath=//div[@id='collapseLots']//span[contains(text(), '${lot_id}')]
  Sleep  1

Save Tender
  Sleep  1
  JsSetScrollToElementBySelector  \#submitBtn
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
  ${pzo_proc_type}=  Remove String  ${pzo_proc_type}  \.

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
  ${pzo_proc_type}=  Remove String  ${pzo_proc_type}  \.

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
  ${pzo_proc_type}=  Remove String  ${pzo_proc_type}  \.

  Open Tender
  Click Element  xpath=//a[contains(@href, '/tender/update?id=')]
  sleep    1
  wait until page contains element    id=tender-form    10
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
  ${pzo_proc_type}=  Remove String  ${pzo_proc_type}  \.

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
  #Fail  delete lot not supported

  Start Edit Lot  ${lot_id}  # open tender form and open lots

  Click Element  jquery=#collapseLots .nav li[data-title^='${lot_id}'] a[data-toggle='tab']  # open needed lot
  Sleep  500ms
  Click Element  jquery=#collapseLots .nav li[data-title^='${lot_id}'] a[data-toggle='tab'] .js-dynamic-form-remove  # click button to remove lot
  Wait Until Page Contains  Ви впевнені що бажаєте видалити поточний лот?  3
  Click Element  xpath=//div[contains(@class, 'jconfirm-box')]//button[contains(text(), 'Так')]  # confrim deleting
  Wait Until Page Does Not Contain Element  jquery=#collapseLots .nav li[data-title^='${lot_id}'] a[data-toggle='tab']  3

  Save Tender

Додати неціновий показник на тендер
  [Arguments]  ${username}  ${tender_uaid}  ${feature}
  Switch browser   ${username}

  ${procurementMethodType}=  Get From Dictionary  ${USERS.users['${PZO_LOGIN_USER}']}  tender_methodtype
  ${pzo_proc_type}=  Convert_to_Lowercase  ${procurementMethodType}
  ${pzo_proc_type}=  Remove String  ${pzo_proc_type}  \.

  Open Tender
  Click Element  xpath=//a[contains(@href, '/tender/update?id=')]
  sleep    1
  wait until page contains element    id=tender-form    10
  Click Element  xpath=//h4[contains(@class, 'panel-title')]//*[contains(@href, '#collapseFeatures')]
  Sleep  1
  Add Feature  ${feature}  0  ${procurementMethodType}  div[@id='collapseFeatures']  tenderer

  Save Tender

Видалити неціновий показник
  [Arguments]  ${username}  ${tender_uaid}  ${feature_id}
  Switch browser   ${username}

  ${tender_id}=  Get From Dictionary  ${USERS.users['${PZO_LOGIN_USER}']}  TENDER_ID

  Sync Tender
  Go To  ${BROKERS['pzo'].basepage}/tender/update?id=${tender_id}\#showfeaturebytext:${feature_id}
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
  ${pzo_proc_type}=  Remove String  ${pzo_proc_type}  \.

  Start Edit Lot  ${lot_id}
  Add Feature  ${feature}  0  ${procurementMethodType}  div[contains(@class, 'form-group tender${pzo_proc_type}form-lots-dynamic-forms-wrapper')]//div[contains(@class, 'active')]//div[contains(@class, 'form-group lot${pzo_proc_type}form-features-dynamic-forms-wrapper')]  lot

  Save Tender

Додати неціновий показник на предмет
  [Arguments]  ${username}  ${tender_uaid}  ${feature}  ${item_id}
  Switch browser   ${username}

  ${procurementMethodType}=  Get From Dictionary  ${USERS.users['${PZO_LOGIN_USER}']}  tender_methodtype
  ${pzo_proc_type}=  Convert_to_Lowercase  ${procurementMethodType}
  ${pzo_proc_type}=  Remove String  ${pzo_proc_type}  \.
  ${tender_id}=  Get From Dictionary  ${USERS.users['${PZO_LOGIN_USER}']}  TENDER_ID

  Sync Tender
  Go To  ${BROKERS['pzo'].basepage}/tender/update?id=${tender_id}\#showitembytext:${item_id}
  Sleep  2
  Add Feature  ${feature}  0  ${procurementMethodType}  div[contains(@class, 'form-group tender${pzo_proc_type}form-lots-dynamic-forms-wrapper')]//div[contains(@class, 'active')]//div[contains(@class, 'form-group lot${pzo_proc_type}form-items-dynamic-forms-wrapper')]//div[contains(@class, 'item${pzo_proc_type}form-features-dynamic-forms-wrapper')]  item

  Save Tender

Відповісти на запитання
  [Arguments]  ${username}  ${tender_uaid}  ${answer}  ${question_id}
  Switch browser   ${username}

  ${tender_id}=  Get From Dictionary  ${USERS.users['${PZO_LOGIN_USER}']}  TENDER_ID

  Sync Tender
  Go To  ${BROKERS['pzo'].basepage}/tender/question-answer?id=${tender_id}
  Click Element  xpath=//select[@id='questionanswerform-pk']
  Click Element  xpath=//select[@id='questionanswerform-pk']//option[contains(text(), '${question_id}')]
  Input text  xpath=//textarea[contains(@id, 'questionanswerform-answer')]  ${answer.data.answer}

  Click Element   xpath=//button[contains(text(), 'Надати відповідь')]
  Sleep  1
  Click Element   xpath=//div[contains(@class, 'jconfirm')]//button[contains(text(), 'Закрити')]
  Sleep  2

  WaitPageSyncing  60

Відповісти на вимогу
  [Arguments]  ${username}  ${tender_uaid}  ${claim_id}  ${answer}  ${award_index}
  Switch browser   ${username}

  ${tender_id}=  Get From Dictionary  ${USERS.users['${PZO_LOGIN_USER}']}  TENDER_ID

  Sync Tender
  Go To  ${BROKERS['pzo'].basepage}/tender/complaint-answer?id=${tender_id}
  Input text  xpath=//textarea[contains(@id, 'complaintanswerform-resolution')]  ${answer.data.resolution}
  Run Keyword If  '${answer.data.resolutionType}' == 'resolved'  Select From List By Label  xpath=//select[@id='complaintanswerform-resolution_type']  Задоволено
  Run Keyword If  '${answer.data.resolutionType}' == 'declined'  Select From List By Label  xpath=//select[@id='complaintanswerform-resolution_type']  Відхилено
  Run Keyword If  '${answer.data.resolutionType}' == 'invalid'  Select From List By Label  xpath=//select[@id='complaintanswerform-resolution_type']  Не задоволено
  Input text  xpath=//textarea[contains(@id, 'complaintanswerform-tenderer_action')]  ${answer.data.tendererAction}

  Click Element   xpath=//button[contains(text(), 'Надати відповідь')]
  Sleep  1
  Click Element   xpath=//div[contains(@class, 'jconfirm')]//button[contains(text(), 'Закрити')]
  Sleep  2

  WaitPageSyncing  60

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

  #workaround
  ${proposal_id} =  Set Variable If  '-1' == '${proposal_id}'  1  ${proposal_id}
  ${proposal_id} =  Set Variable If  '-2' == '${proposal_id}'  2  ${proposal_id}

  ${doc_contents}=  Get File  ${doc_name}
  Set To Dictionary  ${USERS.users['${PZO_LOGIN_USER}']}  proposal${proposal_id}_document=${doc_name}
  Set To Dictionary  ${USERS.users['${PZO_LOGIN_USER}']}  proposal${proposal_id}_document_contents=${doc_contents}

Відхилити кваліфікацію
  [Arguments]  ${username}  ${tender_uaid}  ${proposal_id}
  Switch browser   ${username}

  #workaround
  ${proposal_id} =  Set Variable If  '-1' == '${proposal_id}'  1  ${proposal_id}
  ${proposal_id} =  Set Variable If  '-2' == '${proposal_id}'  2  ${proposal_id}

  Відкрити форму прекваліфікації і потрібну кваліфікацію  ${proposal_id}
  Click Element   id=prequalificationform-decision
  Click Element   jquery=#prequalificationform-decision option[value='decline']
  Wait Until Page Contains Element  id=prequalificationform-description
  Click Element   jquery=#prequalificationform-title option.js-decline:first
  Input text  id=prequalificationform-description  GenerateFakeText
  ${doc_name}=  Завантажити збережений документ у форму кваліфікації  ${proposal_id}
  Завантажити рішення кваліфікації і накласти ЕЦП і повернутися на перегляд закупівлі
  Remove File  ${doc_name}

Скасувати кваліфікацію
  [Arguments]  ${username}  ${tender_uaid}  ${proposal_id}
  Switch browser   ${username}

  Відкрити форму прекваліфікації і потрібну кваліфікацію  ${proposal_id}
  Click Element   id=prequalificationform-decision
  Click Element   jquery=#prequalificationform-decision option[value='cancel']
  Wait Until Page Contains Element  id=prequalificationform-description
  Run Keyword And Ignore Error  Click Element   jquery=#prequalificationform-title option.js-cancel:first
  Input text  id=prequalificationform-description  GenerateFakeText
  Підтвердити рішення кваліфікації і повернутися на перегляд закупівлі

Підтвердити кваліфікацію
  [Arguments]  ${username}  ${tender_uaid}  ${proposal_id}
  Switch browser   ${username}

  #workaround
  ${proposal_id} =  Set Variable If  '-1' == '${proposal_id}'  1  ${proposal_id}
  ${proposal_id} =  Set Variable If  '-2' == '${proposal_id}'  2  ${proposal_id}

  # handle sign not loaded
  : FOR    ${INDEX}    IN RANGE    0    10
  \  Відкрити форму прекваліфікації і потрібну кваліфікацію  ${proposal_id}
  \  Select From List By Label  xpath=//select[@id='prequalificationform-decision']  Підтвердити
  \  ${doc_name}=  Завантажити збережений документ у форму кваліфікації  ${proposal_id}
  \  Click Element  id=prequalificationform-eligible
  \  Click Element  id=prequalificationform-qualified
  \  ${passed}=  run keyword and return status  Завантажити рішення кваліфікації і накласти ЕЦП і повернутися на перегляд закупівлі
  \  run keyword if  ${passed} == True  Remove File  ${doc_name}
  \  run keyword if  ${passed} == False  sleep  30
  \  exit for loop if  ${passed} == True

Відкрити форму прекваліфікації і потрібну кваліфікацію
  [Arguments]  ${proposal_index}

  Open Tender
  Click Element  xpath=//div[contains(@class, 'aside-menu ')]//a[contains(@href, '/tender/prequalification?id=')]
  wait until page contains element  id=tender-prequalification-form  10

  Click Element  id=prequalificationform-qualification
  Click Element  jquery=select#prequalificationform-qualification option:eq(${proposal_index})
  Sleep  2

  JsSetScrollToElementBySelector  \#prequalificationform-decision

Завантажити збережений документ у форму кваліфікації
  [Arguments]  ${proposal_index}

  ${doc_isset}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${USERS.users['${PZO_LOGIN_USER}']}  proposal${proposal_index}_document
  ${doc_name}=  Run Keyword If  ${doc_isset}  Get From Dictionary  ${USERS.users['${PZO_LOGIN_USER}']}  proposal${proposal_index}_document
  ${doc_contents}=  Run Keyword If  ${doc_isset}  Get From Dictionary  ${USERS.users['${PZO_LOGIN_USER}']}  proposal${proposal_index}_document_contents
  Run Keyword If  ${doc_isset}  Create File  ${doc_name}  ${doc_contents}
  ${doc_name}=  Run Keyword If  ${doc_isset} == False  GenerateFakeDocument
    ...  ELSE  Set Variable  ${doc_name}

  JsSetScrollToElementBySelector  \#prequalification-documents
  Choose File  xpath=//div[contains(@id, 'fileuploadbtnwrapper')]//input[@type='file']  ${doc_name}
  Sleep  2

  [return]  ${doc_name}

Підтвердити рішення кваліфікації і повернутися на перегляд закупівлі
  JsSetScrollToElementBySelector  \#tender-prequalification-form .js-submit-btn
  Click Button  jquery=#tender-prequalification-form .js-submit-btn
  Wait Until Page Contains Element  xpath=//div[contains(@class, 'jconfirm')]//*[text()='Закрити']  20
  Click Button  xpath=//div[contains(@class, 'jconfirm')]//*[text()='Закрити']
  Sleep  3

  Open Tender

Завантажити рішення кваліфікації і накласти ЕЦП і повернутися на перегляд закупівлі
  JsSetScrollToElementBySelector  \#tender-prequalification-form .js-submit-btn  
  Click Button  jquery=#tender-prequalification-form .js-submit-btn
  Wait Until Page Contains Element  xpath=//div[contains(@class, 'jconfirm')]//*[text()='Закрити']  20 
  Click Button  xpath=//div[contains(@class, 'jconfirm')]//*[text()='Закрити']
  Sleep  3

  Capture Page Screenshot
  Click Button  xpath=//*[text()='Накласти ЕЦП']
  Sleep  1
  Load Sign
  Wait Until Page Contains  ЕЦП успішно накладено на рішення  20
  Click Button  xpath=//div[contains(@class, 'jconfirm')]//*[text()='Закрити']
  Sleep  3

  Підтвердити рішення кваліфікації і повернутися на перегляд закупівлі

Затвердити остаточне рішення кваліфікації
  [Arguments]  ${username}  ${tender_uaid}
  Switch browser   ${username}

  Open Tender

  Click Element  xpath=//a[contains(@href, '/tender/prequalification-approve?id=')]
  Sleep  1
  Click Button  xpath=//*[text()='Так']
  Wait Until Page Contains  Прекваліфікація підтверджена  20
  Click Button  xpath=//div[contains(@class, 'jconfirm')]//*[text()='Закрити']

  Sleep  2
  WaitPageSyncing  300

### BOF - Competitive Dialogue ###
Перевести тендер на статус очікування обробки мостом
  [Arguments]  ${username}  ${tender_uaid}
  Switch browser   ${username}

  Open Tender
  WaitTenderStage2  1800

  Click Element  xpath=//a[contains(@href, '/tender/confirm-stage2?id=')]
  Sleep  1
  Click Button  xpath=//*[text()='Так']
  Wait Until Page Contains  Підтвердження успішно надане  20
  Click Button  xpath=//div[contains(@class, 'jconfirm')]//*[text()='Закрити']

  Sleep  2
  WaitPageSyncing  300

WaitTenderStage2
  [Arguments]  ${timeout}
  ${passed}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  ${timeout} s  0 s  GetIsTenderReadyForStage2
  Run Keyword Unless  ${passed}  Fatal Error  Tender stage2 was not appeared in ${timeout} sec

GetIsTenderReadyForStage2
  Sleep  30
  Reload Page
  Sleep  1
  Page Should Contain  Підтвердження другого епату

Отримати тендер другого етапу та зберегти його
  [Arguments]  ${username}  ${stage2_tender_uaid}
  Switch browser   ${username}

  Add id to tender

активувати другий етап
  [Arguments]  ${username}  ${stage2_tender_uaid}
  Switch browser   ${username}

  ${current_tender_uaid}=  Отримати інформацію із тендера tenderID
  Run Keyword If  '${current_tender_uaid}' != '${stage2_tender_uaid}'  Go To  ${BROKERS['pzo'].basepage}/tender/${stage2_tender_uaid}
  WaitTenderStage2Update  1800

  Click Element  xpath=//a[contains(@href, '/tender/update?id=')]
  sleep    1
  wait until page contains element    id=tender-form    10

  ${tender_end_date}=  Get Current Date  increment=00:25:00  result_format=%d.%m.%Y %H:%M
  JsSetScrollToElementBySelector  \#tendercompetitivedialogueuastage2form-tender_period_end_date
  Input Converted DateTime  \#tendercompetitivedialogueuastage2form-tender_period_end_date  ${tender_end_date}
  ${draftchecked}=  execute javascript  return $('#tendercompetitivedialogueuastage2form-draft_mode').is(":checked") ? 1 : 0;
  run keyword if  '${draftchecked}' == '1'  click Element  id=tendercompetitivedialogueuastage2form-draft_mode

  Save Tender

WaitTenderStage2Update
  [Arguments]  ${timeout}
  ${passed}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  ${timeout} s  0 s  GetIsTenderReadyForStage2Update
  Run Keyword Unless  ${passed}  Fatal Error  Tender stage2 can not be updated in ${timeout} sec

GetIsTenderReadyForStage2Update
  Sleep  30
  Reload Page
  Sleep  1
  Page Should Contain Element  xpath=//a[contains(@href, '/tender/update?id=')]

### EOF - Competitive Dialogue ###

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
  Click Element   xpath=//div[contains(@class, 'jconfirm')]//button[contains(text(), 'Закрити')]

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
  Sleep  3
  Reload Page
  Page Should Not Contain Element  xpath=//i[@class='fa fa-spin fa-refresh']

Створити вимогу
  [Arguments]  ${username}  ${tender_uaid}  ${type}  ${type_id}  ${claim}  ${doc_name}
  Switch browser  ${username}
  Open Tender
  Capture Page Screenshot
  Click Element  xpath=//a[contains(@href, '/tender/complaint-create?id=')]  
  Wait Until Page Contains Element  xpath=//div[contains(@class, 'complaint-create-form-wrapper')]  10
  # fill complaintform
  Run Keyword And Ignore Error  Run Keyword If  '${type}' == 'tender'  Select From List By Label  xpath=//select[@id='complaintform-related_of']  Закупівля
  Run Keyword And Ignore Error  Run Keyword If  '${type}' == 'lot'  Select From List By Label  xpath=//select[@id='complaintform-related_of']  Лот
  Run Keyword And Ignore Error  Run Keyword If  '${type}' == 'lot'  Click Element  xpath=//select[@id='complaintform-related_lot']
  Run Keyword And Ignore Error  Run Keyword If  '${type}' == 'lot'  Click Element  xpath=//select[@id='complaintform-related_lot']//option[contains(text(), '${type_id}')]
  Run Keyword And Ignore Error  Select From List By Label  xpath=//select[@id='complaintform-type']  Вимога
  Run Keyword And Ignore Error  Input text  xpath=//input[contains(@id, 'complaintform-title')]  ${claim.data.title}
  Run Keyword And Ignore Error  Input text  xpath=//textarea[contains(@id, 'complaintform-description')]  ${claim.data.description}
  # fill awardcomplaintform
  Run Keyword And Ignore Error  Click Element  jquery=#awardcomplaintform-award
  Run Keyword And Ignore Error  Click Element  jquery=#awardcomplaintform-award option:first
  Run Keyword And Ignore Error  Select From List By Label  xpath=//select[@id='awardcomplaintform-type']  Вимога
  Run Keyword And Ignore Error  Run Keyword If  '${type}' == 'winner_complaint'  Select From List By Label  xpath=//select[@id='awardcomplaintform-type']  Скарга
  Run Keyword And Ignore Error  Input text  xpath=//input[contains(@id, 'awardcomplaintform-title')]  ${claim.data.title}
  Run Keyword And Ignore Error  Input text  xpath=//textarea[contains(@id, 'awardcomplaintform-description')]  ${claim.data.description}
  # upload document
  Run Keyword If  '${doc_name}' != 'null'  Click Element  xpath=//a[contains(@data-url, '/tender/get-complaint-document-form')]
  Run Keyword If  '${doc_name}' != 'null'  Wait Until Page Contains Element  xpath=//input[@type='file']  10
  Run Keyword If  '${doc_name}' != 'null'  Choose File  xpath=//input[@type='file']  ${doc_name}
  Run Keyword If  '${doc_name}' != 'null'  Sleep  2
  Click Element   xpath=//button[contains(text(), 'Створити')]
  Sleep  1
  Click Element   xpath=//div[contains(@class, 'jconfirm')]//button[contains(text(), 'Закрити')]
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

Створити скаргу про виправлення визначення переможця
  [Arguments]  ${username}  ${tender_uaid}  ${claim}  ${proposal_id}  ${doc_name}
  Run Keyword And Return  Створити вимогу  ${username}  ${tender_uaid}  winner_complaint  ${proposal_id}  ${claim}  ${doc_name}

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
  Click Element   xpath=//div[contains(@class, 'jconfirm')]//button[contains(text(), 'Закрити')]

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
  Go To  ${BROKERS['pzo'].basepage}/tender/complaint-resolve?id=${tender_id}
  Wait Until Page Contains Element  xpath=//select[@id='complaintresolveform-complaint']  10
  Click Element  xpath=//select[@id='complaintresolveform-complaint']
  Click Element  xpath=//select[@id='complaintresolveform-complaint']//option[@data-complaintid='${claim}']
  #
  Run Keyword If  '${data.data.satisfied}' == 'True'  Select From List By Label  xpath=//select[@id='complaintresolveform-satisfied']  Задовільнена
  Run Keyword If  '${data.data.satisfied}' == 'False'  Select From List By Label  xpath=//select[@id='complaintresolveform-satisfied']  Не задовільнена
  #
  Click Element   xpath=//button[contains(text(), 'Надати рішення')]
  Sleep  1
  Click Element   xpath=//div[contains(@class, 'jconfirm')]//button[contains(text(), 'Закрити')]

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
  Click Element   xpath=//div[contains(@class, 'jconfirm')]//button[contains(text(), 'Закрити')]
  Sleep  2
  Wait For All Transfer Complete

Скасувати цінову пропозицію
  [Arguments]  ${username}  ${tender_uaid}

  Switch browser  ${username}
  Open Tender

  ${canbedone}=  run keyword and return status  page should contain element  jquery=.aside-part .js-bid-delete
  run keyword if  ${canbedone}  fail  Скасування неможливе

  Click Element   jquery=.aside-part .js-bid-delete
  Sleep  1
  Click Element  xpath=//div[contains(@class, 'jconfirm-box')]//button[contains(text(), 'Так')]
  wait until page contains  Пропозиція скасована
  Click Element   xpath=//div[contains(@class, 'jconfirm')]//button[contains(text(), 'Закрити')]
  Sleep  10
  reload page
  sleep  2

Подати цінову пропозицію Lots
  [Arguments]  ${username}  ${tender_uaid}  ${bid}  ${lots_ids}  ${features_ids}
  Switch browser  ${username}

  ${tender_id}=  Get From Dictionary  ${USERS.users['${PZO_LOGIN_USER}']}  TENDER_ID
  ${bid_data_keys}=  Get Dictionary Keys  ${bid.data}
  ${lots}=  Get From Dictionary  ${bid.data}  lotValues
  ${lots_length}=  Get Length  ${lots}

  Open Tender
  ${procurementMethodType}=  Отримати інформацію із тендера procurementMethodType
  Go To  ${BROKERS['pzo'].basepage}/tender/bid?id=${tender_id}
  sleep  1

  : FOR    ${INDEX}    IN RANGE    0    ${lots_length}
  \   Set To Dictionary  ${USERS.users['${PZO_LOGIN_USER}']}  last_proposal_lotid=${lots[${INDEX}].relatedLot}
  \   execute javascript  robottesthelpfunctions.showlotbykey("${lots[${INDEX}].relatedLot}")
  \   Sleep  1
  \   Run Keyword And Ignore Error  Подати цінову пропозицію Amount  ${lots[${INDEX}].value.amount}
  \   Run Keyword If  '${procurementMethodType}' == 'esco'  Подати цінову пропозицію Esco  ${lots[${INDEX}].value}
  \   Run Keyword If  '${procurementMethodType}' != 'belowThreshold'  Input text  xpath=//div[contains(@class, 'active')]//textarea[contains(@id, '-subcontracting_details')]  ${bid.data.tenderers[0].name}
  \   Run Keyword If  '${procurementMethodType}' != 'belowThreshold'  Click Element  xpath=//div[contains(@class, 'active')]//input[contains(@id, '-self_eligible')]
  \   Run Keyword If  '${procurementMethodType}' != 'belowThreshold'  Click Element  xpath=//div[contains(@class, 'active')]//input[contains(@id, '-self_qualified')]
  \   Run Keyword If  'parameters' in ${bid_data_keys}  Подати цінову пропозицію Features  ${bid.data.parameters}
  \   Run Keyword If  '${procurementMethodType}' != 'belowThreshold'  Run Keyword If  '${procurementMethodType}' != 'aboveThresholdUA'  Подати цінову пропозицію FakeDocs

Подати цінову пропозицію No Lots
  [Arguments]  ${username}  ${tender_uaid}  ${bid}  ${lots_ids}  ${features_ids}
  Switch browser  ${username}

  ${tender_id}=  Get From Dictionary  ${USERS.users['${PZO_LOGIN_USER}']}  TENDER_ID

  Open Tender
  Go To  ${BROKERS['pzo'].basepage}/tender/bid?id=${tender_id}
  Sleep  2
  ${amount}=  convert_float_to_string  ${bid.data.value.amount}
  Input text  xpath=//input[contains(@id, '-value_amount')]  ${amount}

Подати цінову пропозицію Amount
  [Arguments]  ${amount}
  ${amount}=  convert_float_to_string  ${amount}
  Input text  xpath=//div[contains(@class, 'active')]//input[contains(@id, '-value_amount')]  ${amount}

Подати цінову пропозицію Esco
  [Arguments]  ${value}
  ${value_keys}=  Get Dictionary Keys  ${value}

  run keyword and ignore error  input text  jquery=.tab-pane.js-lot-tab.active [id$='-contract_duration_years']  ${value.contractDuration.years}
  run keyword and ignore error  input text  jquery=.tab-pane.js-lot-tab.active [id$='-contract_duration_days']  ${value.contractDuration.days}
  run keyword if  'yearlyPaymentsPercentage' in ${value_keys}  input float multiply100  .tab-pane.js-lot-tab.active [id$='-yearly_payments_percentage']  ${value.yearlyPaymentsPercentage}
  run keyword if  'annualCostsReduction' in ${value_keys}  Подати цінову пропозицію Esco AnnualCostsReduction  ${value.annualCostsReduction}

Подати цінову пропозицію Esco AnnualCostsReduction
  [Arguments]  ${values}

  ${input_index}=  set variable  1
  : FOR    ${value}    IN    @{values}
  \  input float  .tab-pane.js-lot-tab.active [id$='-annual_costs_reduction_${input_index}']  ${value}
  \  ${input_index}=  evaluate  ${input_index} + 1

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
  ${result}=  Run Keyword And Return Status  Select From List By Label  xpath=//div[contains(@class, 'active')]//div[contains(@class, 'active')]//select[contains(@id, '-document_type')]  Кошторис
  Run Keyword If  ${result} == False  Select From List By Value  xpath=//div[contains(@class, 'active')]//div[contains(@class, 'active')]//select[contains(@id, '-document_type')]  technicalSpecifications
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
  Go To  ${BROKERS['pzo'].basepage}/tender/bid?id=${tender_id}

Start Edit Proposal Lot
  ${tender_id}=  Get From Dictionary  ${USERS.users['${PZO_LOGIN_USER}']}  TENDER_ID
  ${last_proposal_lotid}=  Get From Dictionary  ${USERS.users['${PZO_LOGIN_USER}']}  last_proposal_lotid
  Go To  ${BROKERS['pzo'].basepage}/tender/bid?id=${tender_id}\#showlotbykey:${last_proposal_lotid}

Save Proposal
  Click Element   xpath=//button[contains(text(), 'Редагувати пропозицію')]
  Sleep  1
  Click Element   xpath=//div[contains(@class, 'jconfirm')]//button[contains(text(), 'Закрити')]
  Sleep  2
  Wait For All Transfer Complete

Завантажити документ в ставку
  [Arguments]  ${username}  @{arguments}
  [Documentation]
  ...      ${arguments[0]} ==  file_path
  ...      ${arguments[1]} ==  tender_uaid
  ...      ${arguments[2]} ==  doc_type
  ...      ${arguments[3]} ==  doc_name
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
  @{f_name}=  Split String From Right  ${arguments[0]}  /  1
  Wait Until Page Contains  ${f_name[1]}  20
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
  Run Keyword And Ignore Error  Click Element  xpath=//div[contains(@class, 'active')]//div[contains(@class, 'active')]//input[contains(@id, '-confidentiality')]
  Run Keyword And Ignore Error  Click Element  xpath=//div[contains(@class, 'active')]//div[contains(@class, 'active')]//input[contains(@id, '-is_description_decision')]
  Sleep  1
  Run Keyword And Ignore Error  Input text  xpath=//div[contains(@class, 'active')]//div[contains(@class, 'active')]//textarea[contains(@id, '-confidentiality_rationale')]  ${data.data.confidentialityRationale}
  Sleep  1

  Save Proposal

Змінити цінову пропозицію
  [Arguments]  ${username}  ${tender_uaid}  ${field}  ${value}
  Switch browser  ${username}
  Start Edit Proposal
  ${procurementMethodType}=  Отримати інформацію із тендера procurementMethodType
  Run Keyword If  '${field}' == 'lotValues[0].value.amount' and '${procurementMethodType}' != 'esco'  Подати цінову пропозицію Amount  ${value}
  Sleep  1

  Save Proposal

Завантажити документ рішення кваліфікаційної комісії
  [Arguments]  ${username}  ${doc_name}  ${tender_uaid}  ${award_index}
  Switch browser   ${username}
  ## copy file to another dir to prevent it deleting
  ${new_doc_name}=  Replace String  ${doc_name}  /tmp/  /tmp/pzo/
  Copy File  ${doc_name}  ${new_doc_name}
  Set To Dictionary  ${USERS.users['${PZO_LOGIN_USER}']}  qproposal${award_index}_document=${new_doc_name}

Підтвердити постачальника
  [Arguments]  ${username}  ${tender_uaid}  ${award_index}
  Switch browser   ${username}

  ${doc_isset}=  GetDictionaryKeyExist  ${USERS.users['${PZO_LOGIN_USER}']}  qproposal${award_index}_document
  ${doc_name}=  Run Keyword If  ${doc_isset}  GetValueFromDictionaryByKey  ${USERS.users['${PZO_LOGIN_USER}']}  qproposal${award_index}_document
  ...  ELSE  GenerateFakeDocument

  Відкрити форму кваліфікації переможця і потрібну кваліфікацію  0

  # handle sign not loaded
  : FOR    ${INDEX}    IN RANGE    0    10
  \  run keyword if  ${INDEX} != 0  reload page
  \  select from list by value  xpath=//select[@id='qualificationform-decision']  accept
  \  JsSetScrollToElementBySelector  \#qualification-documents
  \  run keyword if  ${INDEX} == 0  Choose File  xpath=//input[@type='file']  ${doc_name}
  \  run keyword if  ${INDEX} == 0  Sleep  2
  \  JsSetScrollToElementBySelector  .tab-pane.active [id$='-document_type']
  \  run keyword if  ${INDEX} == 0  Select From List By Label  jquery=.tab-pane.active [id$='-document_type']  Повідомлення про рішення
  \  Run Keyword And Ignore Error  Click Element  id=qualificationform-eligible
  \  Run Keyword And Ignore Error  Click Element  id=qualificationform-qualified
  \  ${passed}=  run keyword and return status  Підтвердити рішення кваліфікації переможця
  \  run keyword if  ${passed} == True  Open Tender
  \  run keyword if  ${passed} == False  sleep  30
  \  exit for loop if  ${passed} == True

Дискваліфікувати постачальника
  [Arguments]  ${username}  ${tender_uaid}  ${award_index}
  Switch browser   ${username}

  ${doc_isset}=  GetDictionaryKeyExist  ${USERS.users['${PZO_LOGIN_USER}']}  qproposal${award_index}_document
  ${doc_name}=  Run Keyword If  ${doc_isset}  GetValueFromDictionaryByKey  ${USERS.users['${PZO_LOGIN_USER}']}  qproposal${award_index}_document
  ...  ELSE  GenerateFakeDocument

  Відкрити форму кваліфікації переможця і потрібну кваліфікацію  0

  Select From List By Value   id=qualificationform-decision  decline
  Run Keyword And Ignore Error  Click Element  id=qualificationform-title
  Run Keyword And Ignore Error  Click Element  jquery=#qualificationform-title option.js-cancel:first
  Run Keyword And Ignore Error  Input text  id=qualificationform-description  GenerateFakeText
  JsSetScrollToElementBySelector  \#qualification-documents
  Choose File  xpath=//input[@type='file']  ${doc_name}
  Sleep  2
  JsSetScrollToElementBySelector  .tab-pane.active [id$='-document_type']
  Select From List By Label  jquery=.tab-pane.active [id$='-document_type']  Повідомлення про рішення

  Підтвердити рішення кваліфікації переможця
  Open Tender

Скасування рішення кваліфікаційної комісії
  [Arguments]  ${username}  ${tender_uaid}  ${award_index}
  Switch browser   ${username}

  Відкрити форму кваліфікації переможця і потрібну кваліфікацію  0

  Select From List By Label  xpath=//select[@id='qualificationform-decision']  Скасувати рішення
  Run Keyword And Ignore Error  Click Element  id=qualificationform-title
  Run Keyword And Ignore Error  Click Element  jquery=#qualificationform-title option.js-cancel:first
  Run Keyword And Ignore Error  Input text  id=qualificationform-description  GenerateFakeText

  Підтвердити рішення кваліфікації переможця
  Open Tender

Відкрити форму кваліфікації переможця і потрібну кваліфікацію
  [Arguments]  ${proposal_index}

  Open Tender
  WaitTenderAuctionEnd  3600
  Click Element  xpath=//div[contains(@class, 'aside-menu ')]//a[contains(@href, '/tender/qualification?id=')]
  Wait Until Page Contains  Кваліфікація  10
  Click Element  id=qualificationform-award
  Click Element  jquery=select#qualificationform-award option:eq(${proposal_index})
  Sleep  2

  JsSetScrollToElementBySelector  \#qualificationform-decision

Підтвердити рішення кваліфікації переможця
  JsSetScrollToElementBySelector  \#tender-qualification-form .js-submit-btn
  Click Button  jquery=#tender-qualification-form .js-submit-btn
  Wait Until Page Contains Element  xpath=//div[contains(@class, 'jconfirm')]//*[text()='Закрити']  20
  Click Button  xpath=//div[contains(@class, 'jconfirm')]//*[text()='Закрити']
  Sleep  2

  # check if eds is needed
  ${eds_isset}=  run keyword and return status  Click Button  xpath=//*[text()='Накласти ЕЦП']
  run keyword if  ${eds_isset}  Накласти ЕЦП на відкритий попап та закрити його
  run keyword if  ${eds_isset}  JsSetScrollToElementBySelector  \#tender-qualification-form .js-submit-btn
  run keyword if  ${eds_isset}  Click Button  jquery=#tender-qualification-form .js-submit-btn
  run keyword if  ${eds_isset}  Wait Until Page Contains Element  xpath=//div[contains(@class, 'jconfirm')]//*[text()='Закрити']  20
  run keyword if  ${eds_isset}  Click Button  xpath=//div[contains(@class, 'jconfirm')]//*[text()='Закрити']
  run keyword if  ${eds_isset}  Sleep  3

Накласти ЕЦП на відкритий попап та закрити його

  Sleep  1
  Load Sign
  Wait Until Page Contains  ЕЦП успішно накладено  20
  Click Button  xpath=//div[contains(@class, 'jconfirm')]//*[text()='Закрити']
  Sleep  3

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

  ${current_tender_uaid}=  Отримати інформацію із тендера tenderID

  Run Keyword And Return If   'NBUdiscountRate' == '${arguments[2]}'   Get number from text by locator  jquery=#tender-general-info .nbu-discount-rate .value
  Run Keyword And Return If   'auctionPeriod.startDate' == '${arguments[2]}'   get_invisible_text  jquery=.timeline-info-wrapper .auction-start-date
  Run Keyword And Return If   'lots[0].value.amount' == '${arguments[2]}'   Get invisible text number by locator  jquery=#accordionLots .lot-info-wrapper:first .budget-source.hidden
  Run Keyword And Return If   'lots[0].auctionPeriod.startDate' == '${arguments[2]}'   get_invisible_text  jquery=#accordionLots .lot-info-wrapper:first .auction-period-start-date.hidden
  Run Keyword And Return If   'lots[0].auctionPeriod.endDate' == '${arguments[2]}'   get_invisible_text  jquery=#accordionLots .lot-info-wrapper:first .auction-period-end-date.hidden
  Run Keyword And Return If   'lots[0].minimalStepPercentage' == '${arguments[2]}'   Get invisible text number by locator  jquery=#accordionLots .lot-info-wrapper:first .minimal-step-percentage-source.hidden
  Run Keyword And Return If   'lots[0].fundingKind' == '${arguments[2]}'   get_invisible_text  jquery=#accordionLots .lot-info-wrapper:first .funding-kind-source.hidden
  Run Keyword And Return If   'lots[0].yearlyPaymentsPercentageRange' == '${arguments[2]}'  Get invisible text number by locator   jquery=#accordionLots .lot-info-wrapper:first .yearly-payments-percentage-range-source.hidden
  Run Keyword And Return If   'auctionPeriod.endDate' == '${arguments[2]}'   get_invisible_text  jquery=.timeline-info-wrapper .auction-end-date
  Run Keyword And Return If   'deliveryLocation.longitude' == '${arguments[2]}'   Fail  Не реалізований функціонал
  Run Keyword And Return If   'deliveryLocation.latitude' == '${arguments[2]}'   Fail  Не реалізований функціонал
  Run Keyword And Return If   'tenderPeriod.startDate' == '${arguments[2]}'   Отримати інформацію із тендера tenderPeriod.startDate
  Run Keyword And Return If   'tenderPeriod.endDate' == '${arguments[2]}'   Отримати інформацію із тендера tenderPeriod.endDate
  Run Keyword And Return If   'procurementMethodType' == '${arguments[2]}'   Отримати інформацію із тендера procurementMethodType
  Run Keyword And Return If   'value.amount' == '${arguments[2]}'   Отримати інформацію із тендера value.amount
  Run Keyword If   'status' == '${arguments[2]}' and '${current_tender_uaid}' != '${arguments[1]}'   Reload Page
  Run Keyword If   'status' == '${arguments[2]}' and '${current_tender_uaid}' != '${arguments[1]}'   Sleep  3
  Run Keyword And Return If   'status' == '${arguments[2]}' and '${current_tender_uaid}' != '${arguments[1]}'   get_invisible_text  xpath=//*[contains(@class, 'hidden stage2.opstatus')]
  Run Keyword And Return If   'status' == '${arguments[2]}'   Отримати інформацію із тендера status
  Run Keyword And Return If   'enquiryPeriod.startDate' == '${arguments[2]}'   get_invisible_text  jquery=.timeline-info-wrapper .enquiry-period-start-date.hidden
  Run Keyword And Return If   'enquiryPeriod.endDate' == '${arguments[2]}'   get_invisible_text  jquery=.timeline-info-wrapper .enquiry-period-end-date.hidden
  Run Keyword And Return If   'complaintPeriod.startDate' == '${arguments[2]}'   Отримати інформацію із тендера complaintPeriod.startDate
  Run Keyword And Return If   'complaintPeriod.endDate' == '${arguments[2]}'   Отримати інформацію із тендера complaintPeriod.endDate
  Run Keyword And Return If   'title' == '${arguments[2]}'   Отримати інформацію із тендера title
  Run Keyword And Return If   'description' == '${arguments[2]}'   Отримати інформацію із тендера description
  Run Keyword And Return If   'value.currency' == '${arguments[2]}'   Отримати інформацію із тендера value.currency
  Run Keyword And Return If   'value.valueAddedTaxIncluded' == '${arguments[2]}'   Отримати інформацію із тендера value.valueAddedTaxIncluded
  Run Keyword And Return If   'tenderID' == '${arguments[2]}'   Отримати інформацію із тендера tenderID
  Run Keyword And Return If   'stage2TenderID' == '${arguments[2]}'   Отримати інформацію із тендера stage2tenderID
  Run Keyword And Return If   'procuringEntity.name' == '${arguments[2]}'   Отримати інформацію із тендера procuringEntity.name
  Run Keyword And Return If   'minimalStep.amount' == '${arguments[2]}'   Отримати інформацію із тендера minimalStep.amount
  Run Keyword And Return If   'bids' == '${arguments[2]}'   Fail  Unable to see bids
  Run Keyword And Return If   'qualifications[0].status' == '${arguments[2]}'  Отримати інформацію із тендера qualifications[0].status
  Run Keyword And Return If   'qualifications[1].status' == '${arguments[2]}'  Отримати інформацію із тендера qualifications[1].status
  Run Keyword If   'qualificationPeriod.endDate' == '${arguments[2]}'  Open Tender
  Run Keyword And Return If   'qualificationPeriod.endDate' == '${arguments[2]}'  Отримати інформацію із тендера qualificationPeriod.endDate
  Run Keyword And Return If   'questions[0].title' == '${arguments[2]}'  Отримати інформацію із тендера questions.title  ${arguments[0]}  ${arguments[1]}  0
  Run Keyword And Return If   'questions[1].title' == '${arguments[2]}'  Отримати інформацію із тендера questions.title  ${arguments[0]}  ${arguments[1]}  1
  Run Keyword And Return If   'questions[2].title' == '${arguments[2]}'  Отримати інформацію із тендера questions.title  ${arguments[0]}  ${arguments[1]}  2
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
  Run Keyword If   'awards[0].complaintPeriod.endDate' == '${arguments[2]}'  Open Tender
  ${Result}=  Run Keyword And Return Status  Page Should Contain Element  jquery=div.award-list-wrapper .panel-heading:eq(0) a[data-toggle="collapse"]
  Run Keyword If   'awards[0].complaintPeriod.endDate' == '${arguments[2]}' and ${RESULT}  JsOpenAwardByIndex  0
  Run Keyword If   'awards[0].complaintPeriod.endDate' == '${arguments[2]}' and ${RESULT}  JsSetScrollToElementBySelector  div.award-list-wrapper
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
  Run Keyword If   'awards[1].value.amount' == '${arguments[2]}'   JsOpenAwardByIndex  1
  Run Keyword And Return If   'awards[1].value.amount' == '${arguments[2]}'   Get invisible text number by locator  jquery=.award-list-wrapper .panel-collapse.in .award-info-wrapper p.budget-amount
  Run Keyword If   'awards[2].value.amount' == '${arguments[2]}'   JsOpenAwardByIndex  2
  Run Keyword And Return If   'awards[2].value.amount' == '${arguments[2]}'   Get invisible text number by locator  jquery=.award-list-wrapper .panel-collapse.in .award-info-wrapper p.budget-amount
  Run Keyword If   'awards[0].suppliers[0].contactPoint.name' == '${arguments[2]}'   JsOpenAwardByIndex  0
  Run Keyword And Return If   'awards[0].suppliers[0].contactPoint.name' == '${arguments[2]}'   Get invisible text by locator  jquery=.award-list-wrapper .panel-collapse.in .award-info-wrapper p.organization-contact-point-name
  Run Keyword If   'contracts[0].status' == '${arguments[2]}'   JsOpenContractByIndex  0
  Run Keyword And Return If   'contracts[0].status' == '${arguments[2]}'   Get invisible text by locator  jquery=#accordionContracts .panel-collapse.in .contract-info-wrapper p.status-source

  ${contract1NeedToBeVisible}=  Run Keyword And Return Status  Should Start With  ${arguments[2]}  contracts[1]
  Run Keyword If   ${contract1NeedToBeVisible}  Execute JavaScript  robottesthelpfunctions.showcontractbyindex(1);
  Run Keyword If   ${contract1NeedToBeVisible}  Sleep  2
  Run Keyword And Return If   'contracts[1].dateSigned' == '${arguments[2]}'   Get invisible text by locator  jquery=#accordionContracts .panel-collapse.in .contract-info-wrapper p.date-signed-source.hidden
  Run Keyword And Return If   'contracts[1].period.startDate' == '${arguments[2]}'   Get invisible text by locator  jquery=#accordionContracts .panel-collapse.in .contract-info-wrapper p.period-start-date.hidden
  Run Keyword And Return If   'contracts[1].period.endDate' == '${arguments[2]}'   Get invisible text by locator  jquery=#accordionContracts .panel-collapse.in .contract-info-wrapper p.period-end-date.hidden
  Run Keyword And Return If   'contracts[1].status' == '${arguments[2]}'   Get invisible text by locator  jquery=#accordionContracts .panel-collapse.in .contract-info-wrapper p.status-source
#
  Run Keyword If   'items[0].description' == '${arguments[2]}'  Open Tender
  Run Keyword If   'items[0].description' == '${arguments[2]}'  Execute JavaScript  robottesthelpfunctions.showitembyindex(0);
  Run Keyword If   'items[0].description' == '${arguments[2]}'  Sleep  2
  Run Keyword And Return If   'items[0].description' == '${arguments[2]}'  Get Text  jquery=div[id^='accordionItems']:visible .panel-item-collapse.in .item-info-wrapper p.title .value

  # lots
  Run Keyword And Return If   'lots[0].title' == '${arguments[2]}'  execute javascript  return $(robottesthelpfunctions.getlotwrapperbyindex(0)).attr('data-title');
  Run Keyword And Return If   'lots[1].title' == '${arguments[2]}'  execute javascript  return $(robottesthelpfunctions.getlotwrapperbyindex(1)).attr('data-title');

  ${item0NeedToBeVisible}=  Run Keyword And Return Status  Should Start With  ${arguments[2]}  items[0]
  Run Keyword If   ${item0NeedToBeVisible}  Execute JavaScript  robottesthelpfunctions.showitembyindex(0);
  Run Keyword If   ${item0NeedToBeVisible}  Sleep  2
  Run Keyword And Return If   'items[0].classification.scheme' == '${arguments[2]}'  get_invisible_text  jquery=div[id^='accordionItems']:visible .panel-item-collapse.in .item-info-wrapper .main-classification-scheme
  Run Keyword And Return If   'items[0].classification.id' == '${arguments[2]}'  get_invisible_text  jquery=div[id^='accordionItems']:visible .panel-item-collapse.in .item-info-wrapper .main-classification-code
  Run Keyword And Return If   'items[0].classification.description' == '${arguments[2]}'  get_invisible_text  jquery=div[id^='accordionItems']:visible .panel-item-collapse.in .item-info-wrapper .main-classification-description
  Run Keyword And Return If   'items[0].additionalClassifications[0].scheme' == '${arguments[2]}'  get_invisible_text  jquery=div[id^='accordionItems']:visible .panel-item-collapse.in .item-info-wrapper .additional-classification-scheme.hidden:first
  Run Keyword And Return If   'items[0].additionalClassifications[0].id' == '${arguments[2]}'  get_invisible_text  jquery=div[id^='accordionItems']:visible .panel-item-collapse.in .item-info-wrapper .additional-classification-code.hidden:first
  Run Keyword And Return If   'items[0].additionalClassifications[0].description' == '${arguments[2]}'  get_invisible_text  jquery=div[id^='accordionItems']:visible .panel-item-collapse.in .item-info-wrapper .additional-classification-description.hidden:first
  Run Keyword And Return If   'items[0].quantity' == '${arguments[2]}'  Get invisible text number by locator  jquery=div[id^='accordionItems']:visible .panel-item-collapse.in .item-info-wrapper .quantity-source
  Run Keyword And Return If   'items[0].unit.name' == '${arguments[2]}'  get_invisible_text  jquery=div[id^='accordionItems']:visible .panel-item-collapse.in .item-info-wrapper .unit-title-source
  Run Keyword And Return If   'items[0].unit.code' == '${arguments[2]}'  get_invisible_text  jquery=div[id^='accordionItems']:visible .panel-item-collapse.in .item-info-wrapper .unit-code-source
  Run Keyword And Return If   'items[0].deliveryDate.startDate' == '${arguments[2]}'  get_invisible_text  jquery=div[id^='accordionItems']:visible .panel-item-collapse.in .item-info-wrapper .delivery-start-date-source.hidden
  Run Keyword And Return If   'items[0].deliveryDate.endDate' == '${arguments[2]}'  get_invisible_text  jquery=div[id^='accordionItems']:visible .panel-item-collapse.in .item-info-wrapper .delivery-end-date-source.hidden
  Run Keyword And Return If   'items[0].deliveryAddress.countryName' == '${arguments[2]}'  Get Text  jquery=div[id^='accordionItems']:visible .panel-item-collapse.in .item-info-wrapper .delivery .country
  Run Keyword And Return If   'items[0].deliveryAddress.postalCode' == '${arguments[2]}'  Get Text  jquery=div[id^='accordionItems']:visible .panel-item-collapse.in .item-info-wrapper .delivery .postcode
  Run Keyword And Return If   'items[0].deliveryAddress.region' == '${arguments[2]}'  Get Text  jquery=div[id^='accordionItems']:visible .panel-item-collapse.in .item-info-wrapper .delivery .region
  Run Keyword And Return If   'items[0].deliveryAddress.locality' == '${arguments[2]}'  Get Text  jquery=div[id^='accordionItems']:visible .panel-item-collapse.in .item-info-wrapper .delivery .locality
  Run Keyword And Return If   'items[0].deliveryAddress.streetAddress' == '${arguments[2]}'  Get Text  jquery=div[id^='accordionItems']:visible .panel-item-collapse.in .item-info-wrapper .delivery .street-address
  Run Keyword And Return If   'items[0].deliveryLocation.latitude' == '${arguments[2]}'  Get invisible text number by locator  jquery=div[id^='accordionItems']:visible .panel-item-collapse.in .item-info-wrapper .delivery-latitude.hidden
  Run Keyword And Return If   'items[0].deliveryLocation.longitude' == '${arguments[2]}'  Get invisible text number by locator  jquery=div[id^='accordionItems']:visible .panel-item-collapse.in .item-info-wrapper .delivery-longitude.hidden

  ${item1NeedToBeVisible}=  Run Keyword And Return Status  Should Start With  ${arguments[2]}  items[1]
  Run Keyword If   ${item1NeedToBeVisible}  Execute JavaScript  robottesthelpfunctions.showitembyindex(1);
  Run Keyword If   ${item1NeedToBeVisible}  Sleep  2
  Run Keyword And Return If   'items[1].description' == '${arguments[2]}'  Get Text  jquery=div[id^='accordionItems']:visible .panel-item-collapse.in .item-info-wrapper p.title .value
  Run Keyword And Return If   'items[1].classification.scheme' == '${arguments[2]}'  get_invisible_text  jquery=div[id^='accordionItems']:visible .panel-item-collapse.in .item-info-wrapper .main-classification-scheme
  Run Keyword And Return If   'items[1].classification.id' == '${arguments[2]}'  get_invisible_text  jquery=div[id^='accordionItems']:visible .panel-item-collapse.in .item-info-wrapper .main-classification-code
  Run Keyword And Return If   'items[1].classification.description' == '${arguments[2]}'  get_invisible_text  jquery=div[id^='accordionItems']:visible .panel-item-collapse.in .item-info-wrapper .main-classification-description
  Run Keyword And Return If   'items[1].quantity' == '${arguments[2]}'  Get invisible text number by locator  jquery=div[id^='accordionItems']:visible .panel-item-collapse.in .item-info-wrapper .quantity-source
  Run Keyword And Return If   'items[1].unit.name' == '${arguments[2]}'  get_invisible_text  jquery=div[id^='accordionItems']:visible .panel-item-collapse.in .item-info-wrapper .unit-title-source
  Run Keyword And Return If   'items[1].unit.code' == '${arguments[2]}'  get_invisible_text  jquery=div[id^='accordionItems']:visible .panel-item-collapse.in .item-info-wrapper .unit-code-source
  Run Keyword And Return If   'items[1].deliveryDate.startDate' == '${arguments[2]}'  get_invisible_text  jquery=div[id^='accordionItems']:visible .panel-item-collapse.in .item-info-wrapper .delivery-start-date-source.hidden
  Run Keyword And Return If   'items[1].deliveryDate.endDate' == '${arguments[2]}'  get_invisible_text  jquery=div[id^='accordionItems']:visible .panel-item-collapse.in .item-info-wrapper .delivery-end-date-source.hidden
  Run Keyword And Return If   'items[1].deliveryAddress.countryName' == '${arguments[2]}'  Get Text  jquery=div[id^='accordionItems']:visible .panel-item-collapse.in .item-info-wrapper .delivery .country
  Run Keyword And Return If   'items[1].deliveryAddress.postalCode' == '${arguments[2]}'  Get Text  jquery=div[id^='accordionItems']:visible .panel-item-collapse.in .item-info-wrapper .delivery .postcode
  Run Keyword And Return If   'items[1].deliveryAddress.region' == '${arguments[2]}'  Get Text  jquery=div[id^='accordionItems']:visible .panel-item-collapse.in .item-info-wrapper .delivery .region
  Run Keyword And Return If   'items[1].deliveryAddress.locality' == '${arguments[2]}'  Get Text  jquery=div[id^='accordionItems']:visible .panel-item-collapse.in .item-info-wrapper .delivery .locality
  Run Keyword And Return If   'items[1].deliveryAddress.streetAddress' == '${arguments[2]}'  Get Text  jquery=div[id^='accordionItems']:visible .panel-item-collapse.in .item-info-wrapper .delivery .street-address
  Run Keyword And Return If   'items[1].deliveryLocation.latitude' == '${arguments[2]}'  Get invisible text number by locator  jquery=div[id^='accordionItems']:visible .panel-item-collapse.in .item-info-wrapper .delivery-latitude.hidden
  Run Keyword And Return If   'items[1].deliveryLocation.longitude' == '${arguments[2]}'  Get invisible text number by locator  jquery=div[id^='accordionItems']:visible .panel-item-collapse.in .item-info-wrapper .delivery-longitude.hidden

  ${item2NeedToBeVisible}=  Run Keyword And Return Status  Should Start With  ${arguments[2]}  items[2]
  Run Keyword If   ${item2NeedToBeVisible}  Execute JavaScript  robottesthelpfunctions.showitembyindex(2);
  Run Keyword If   ${item2NeedToBeVisible}  Sleep  2
  Run Keyword And Return If   'items[2].description' == '${arguments[2]}'  Get Text  jquery=div[id^='accordionItems']:visible .panel-item-collapse.in .item-info-wrapper p.title .value

  ### BOF - BelowFunders ###
  ${funderWrapper}=  Set Variable  \#funderorganizationinfo
  Run Keyword And Return If   '${arguments[2]}' == 'funders[0].name'  get_invisible_text  jquery=${funderWrapper} .name.hidden
  Run Keyword And Return If   '${arguments[2]}' == 'funders[0].address.countryName'  get_invisible_text  jquery=${funderWrapper} .country.hidden
  Run Keyword And Return If   '${arguments[2]}' == 'funders[0].address.locality'  get_invisible_text  jquery=${funderWrapper} .locality.hidden
  Run Keyword And Return If   '${arguments[2]}' == 'funders[0].address.postalCode'  get_invisible_text  jquery=${funderWrapper} .postalcode.hidden
  Run Keyword And Return If   '${arguments[2]}' == 'funders[0].address.region'  get_invisible_text  jquery=${funderWrapper} .region.hidden
  Run Keyword And Return If   '${arguments[2]}' == 'funders[0].address.streetAddress'  get_invisible_text  jquery=${funderWrapper} .street-address.hidden
  Run Keyword And Return If   '${arguments[2]}' == 'funders[0].contactPoint.url'  Fail  Контактні дані не відображаються
  Run Keyword And Return If   '${arguments[2]}' == 'funders[0].identifier.id'  get_invisible_text  jquery=${funderWrapper} .identifier-code.hidden
  Run Keyword If   '${arguments[2]}' == 'funders[0].identifier.legalName'  JsSetScrollToElementBySelector    ${funderWrapper}
  Run Keyword And Return If   '${arguments[2]}' == 'funders[0].identifier.legalName'  get_text  jquery=${funderWrapper} .legal-name .value
  Run Keyword And Return If   '${arguments[2]}' == 'funders[0].identifier.scheme'  get_invisible_text  jquery=${funderWrapper} .identifier-scheme.hidden
  ### EOF - BelowFunders ###

  ### BOF - OpenUaDefense ###
  Run Keyword And Return If   '${arguments[2]}' == 'enquiryPeriod.clarificationsUntil'  get_invisible_text  jquery=.enquiry-period-clarifications-until.hidden
  ### EOF - OpenUaDefense ###

  ### BOF - OpenEU ###
  Run Keyword If   '${arguments[2]}' == 'awards[1].complaintPeriod.endDate'  JsOpenAwardByIndex  1
  Run Keyword And Return If   '${arguments[2]}' == 'awards[1].complaintPeriod.endDate'  get_invisible_text  jquery=.award-list-wrapper:first .panel-collapse.in .complaint-period-end-date.hidden
  Run Keyword If   '${arguments[2]}' == 'awards[2].complaintPeriod.endDate'  JsOpenAwardByIndex  2
  Run Keyword And Return If   '${arguments[2]}' == 'awards[2].complaintPeriod.endDate'  get_invisible_text  jquery=.award-list-wrapper:first .panel-collapse.in .complaint-period-end-date.hidden
  ### EOF - OpenEU ###

  ### BOF - Esco ###
  Run Keyword If   '${arguments[2]}' == 'awards[4].complaintPeriod.endDate'  JsOpenAwardByIndex  4
  Run Keyword And Return If   '${arguments[2]}' == 'awards[4].complaintPeriod.endDate'  get_invisible_text  jquery=.award-list-wrapper:first .panel-collapse.in .complaint-period-end-date.hidden
  Run Keyword And Return If   '${arguments[2]}' == 'minimalStepPercentage'  get_invisible_text  jquery=#tender-general-info .minimal-step-percentage-source.hidden
  Run Keyword And Return If   '${arguments[2]}' == 'yearlyPaymentsPercentageRange'  get_invisible_text  jquery=#tender-general-info .yearly-payments-percentage-range-source.hidden
  Run Keyword And Return If   '${arguments[2]}' == 'fundingKind'  get_invisible_text  jquery=#tender-general-info .funding-kind-source.hidden
  ### EOF - Esco ###

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
  Run Keyword And Return If   'auctionPeriod.startDate' == '${arguments[2]}'  get_invisible_text  jquery=#accordionLots .panel-collapse.in .lot-info-wrapper .auction-period-start-date.hidden
  Run Keyword And Return If   'auctionPeriod.endDate' == '${arguments[2]}'  get_invisible_text  jquery=#accordionLots .panel-collapse.in .lot-info-wrapper .auction-period-end-date.hidden
  Run Keyword And Return If   'minimalStepPercentage' == '${arguments[2]}'  Get invisible text number by locator  jquery=#accordionLots .panel-collapse.in .lot-info-wrapper .minimal-step-percentage-source.hidden
  Run Keyword And Return If   'fundingKind' == '${arguments[2]}'   get_invisible_text  jquery=#accordionLots .panel-collapse.in .lot-info-wrapper .funding-kind-source.hidden
  Run Keyword And Return If   'yearlyPaymentsPercentageRange' == '${arguments[2]}'  Get invisible text number by locator   jquery=#accordionLots .panel-collapse.in .lot-info-wrapper .yearly-payments-percentage-range-source.hidden

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
  Run Keyword And Return If   '${MODE}' == 'negotiation' and 'deliveryDate.endDate' == '${arguments[2]}'   Отримати інформацію із предмету deliveryDate.endDateEx
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

  Open Tender With Syncing
  Switch To Questions

  Collapse Question  ${object_id}
  Run Keyword And Return If   'title' == '${field_name}'   get text  jquery=#tender-question-list .panel-collapse.collapse.in .title .value
  Run Keyword And Return If   'answer' == '${field_name}'   get text  jquery=#tender-question-list .panel-collapse.collapse.in .answer .value
  Run Keyword And Return If   'description' == '${field_name}'   get text  jquery=#tender-question-list .panel-collapse.collapse.in .description .value

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
  #execute javascript  jQuery("#tender-question-list .panel-title .title:contains('${question_id}')").trigger('click');
  #Click Element   xpath=//div[@id='tender-question-list']//span[contains(text(),'${question_id}')]
  execute javascript  robottesthelpfunctions.showquestionbykey('${question_id}');
  Sleep  1

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

JsOpenLotByContaintText
  [arguments]  ${text}
  Execute JavaScript  robottesthelpfunctions.showlotbytitle('${text}');
  Sleep  1
  JsSetScrollToElementBySelector  \#lot .panel-lot-collapse.in

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

Get number from text by locator
  [Arguments]  ${locator}
  ${return_value}=  get_text  ${locator}
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

Отримати інформацію із предмету deliveryDate.endDateEx
  ${return_value}=  Get invisible text by locator  jquery=.panel-lot-collapse.in .panel-item-collapse.in .item-info-wrapper p.delivery-end-date
  ${return_value}=  convert_date_for_compare_ex  ${return_value}
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
  ${return_value}=  get_invisible_text  //div[@id='lots']//div[contains(@id,'accordionItems')]//div[contains(@data-title,'${product_id}')]//p[@class='main-classification-scheme hidden']
  Collapse Product  ${product_id}
  Collapse Single Lot
  [return]  ${return_value}

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
  JsOpenLotByContaintText  ${lot_id}
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
  ${return_value}=  get_text  xpath=//div[contains(@class, 'content-part')]//h4[contains(@class, 'page-title')]
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
  ${return_value}=  Get invisible text by locator  jquery=.aside-part .tenderuaid.hidden
  [return]  ${return_value}

Отримати інформацію із тендера stage2tenderID
  ${result}=  Run Keyword And Return Status  Page Should Contain Element  jquery=.stage2-tender-id.hidden
  Run Keyword If  ${result} == False  Sleep  125
  Run Keyword If  ${result} == False  Reload Page
  Run Keyword If  ${result} == False  Sleep  1
  Capture Page Screenshot  getStage2tenderid
  ${return_value}=  Get invisible text by locator  jquery=.stage2-tender-id.hidden
  [return]  ${return_value}

Отримати інформацію із тендера procuringEntity.name
  ${return_value}=  get_text  jquery=#procuringentityinfo .legal-name .value
  [return]  ${return_value}

Отримати інформацію із тендера minimalStep.amount
  ${nolot}=  run keyword and return status  page should contain element  jquery=#tender-general-info .minimal-step-source.hidden
  run keyword and return if  ${nolot}  get invisible text number by locator  jquery=#tender-general-info .minimal-step-source.hidden
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
  Click Element  jquery=div#accordionQualifications > div.panel:eq(0):first a[data-toggle="collapse"]:first
  ${return_value}=  get_invisible_text  jquery=div#accordionQualifications > div.panel:eq(0):first p.status-source:first
  Click Element  jquery=div#accordionQualifications > div.panel:eq(0):first a[data-toggle="collapse"]:first
  [return]  ${return_value}

Отримати інформацію із тендера qualifications[1].status
  Click Element  jquery=div#accordionQualifications > div.panel:eq(1):first a[data-toggle="collapse"]:first
  ${return_value}=  get_invisible_text  jquery=div#accordionQualifications > div.panel:eq(1):first p.status-source:first
  Click Element  jquery=div#accordionQualifications > div.panel:eq(1):first a[data-toggle="collapse"]:first
  [return]  ${return_value}

Отримати інформацію із тендера qualificationPeriod.endDate
  ${return_value}=  get_text  xpath=//p[contains(@class, 'prequalification-period')]//*[@class='value']//span[contains(@class, 'end-date')]
  ${return_value}=  convert_date_for_compare_ex   ${return_value}
  [return]  ${return_value}

Отримати інформацію із тендера questions.title
  [Arguments]  ${username}  ${tender_uaid}  ${index}
  ${return_value}=  pzo.Отримати інформацію із запитання  ${username}  ${tender_uaid}  ${index}  title
  Open Tender Without Syncing
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

### BOF - BELOW FUNDERS ###
Видалити донора
  [Arguments]  ${username}  @{arguments}
  ${tenderid}=  Set Variable  ${arguments[0]}

  TenderFormOpenByUAID  ${tenderid}
  Click Element   id=tenderbelowthresholdform-is_donor
  Save Tender

Додати донора
  [Arguments]  ${username}  @{arguments}
  ${tenderid}=  Set Variable  ${arguments[0]}
  ${funder_data}=  Set Variable  ${arguments[1]}

  TenderFormOpenByUAID  ${tenderid}
  Створити тендер Funder  ${funder_data}
  Save Tender

### EOF - BELOW FUNDERS ###

### BOF - PLANNING ###

Створити план
  [Arguments]  ${user}  ${plan_data}
  ${plan_data}=   procuring_entity_name  ${plan_data}
  ${data}=  Get From Dictionary  ${plan_data}  data
  ${data_keys}=  Get Dictionary Keys  ${data}
  ${start_date}=  convert_isodate_to_site_date  ${data.tender.tenderPeriod.startDate}
  ${budget_keys}=  Get Dictionary Keys  ${data.budget}
  ${classificationWrapper}=  Set Variable  \#collapseGeneral
  ${itemsWrapper}=  Set Variable  a[href='#collapseItems']

  ## preparing
  #UserChangeOrgnizationInfo  ${data.procuringEntity}

  ## load form page
  Go To  ${BROKERS['pzo'].basepage}/plan/create
  Wait Until Page Contains  Створення плану   10
  Sleep  1

  ## filling form
  Select From List By Value  id=planform-procurement_method_type  ${data.tender.procurementMethodType}
  run keyword if  'period' in ${budget_keys}  input datetime  \#planform-period_start_date  ${data.budget.period.startDate}
  run keyword if  'period' in ${budget_keys}  input datetime  \#planform-period_end_date  ${data.budget.period.endDate}
  JsInputHiddenText  \#planform-budget_id  ${data.budget.id}
  Input text  id=planform-title  ${data.budget.description}
  Input Float  \#planform-value_amount  ${data.budget.amount}
  Select From List By Value  id=planform-value_currency  ${data.budget.currency}
  JsInputHiddenText  \#planform-project_id  ${data.budget.project.id}
  JsInputHiddenText  \#planform-project_name  ${data.budget.project.name}
  Input text  id=planform-tender_start_date  ${start_date}
  InputClassificationByWrapper  ${classificationWrapper}  ${data.classification.id}
  Run Keyword If  'additionalClassifications' in ${data_keys}  InputAdditionalClassificationsByWrapper  ${classificationWrapper}  ${data.additionalClassifications}
  Run Keyword If  'items' in ${data_keys}  InputPlanItems  ${data}

  ## submit form
  Click Element   xpath=//*[@id='submitBtn']
  Sleep  1
  Wait Until Page Contains   План закупівлі створений, дочекайтесь опублікування на сайті уповноваженого органу.   10
  Click Element   xpath=//div[contains(@class, 'jconfirm-box')]//button[contains(@class, 'btn btn-default waves-effect waves-light btn-lg')]
  Wait For Sync Tender  60
  ${plan_id}  Get Text  jquery=.content-part .plan-info-wrapper .plan-id .value
  [Return]  ${plan_id}

Пошук плану по ідентифікатору
  [Arguments]  ${username}  ${tenderId}

  Run Keyword If  '${ROLE}' == 'viewer'  Go To  ${BROKERS['pzo'].basepage}/utils/plan-sync?planid=${tenderId}
  Run Keyword If  '${ROLE}' == 'viewer'  Sleep  5
  ${planNotSynced}=  Run Keyword And Return Status  Page Should Contain  fail
  Run Keyword If  '${ROLE}' == 'viewer' and ${planNotSynced}  Go To  ${BROKERS['pzo'].basepage}/utils/queue-plan-update
  Run Keyword If  '${ROLE}' == 'viewer' and ${planNotSynced}  Sleep  30

  Go To  ${BROKERS['pzo'].basepage}/plans
  Wait Until Page Contains Element    id=plansearchform-query    10
  Input Text    id=plansearchform-query    ${tenderId}
  Click Element  jquery=#plan-search-form .js-submit-btn
  Sleep  1
  Wait Until Page Does Not Contain Element  jquery=#plan-list-pjax.loading-wrapper
  Capture Page Screenshot
  Click Element    xpath=(//div[@id='plan-list-pjax'])//a[contains(@href, '/plan/')][1]
  Sleep  5

Оновити сторінку з планом
  [Arguments]  ${username}  ${tenderId}

  Reload Page
  Sleep  2s

Внести зміни в план
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} =  username
  ...      ${ARGUMENTS[1]} =  ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} =  key
  ...      ${ARGUMENTS[3]} =  value

  PlanFormOpenByUAID  ${ARGUMENTS[1]}
  Run Keyword If  '${ARGUMENTS[2]}' == 'budget.amount'  Input text  id=planform-value_amount  ${ARGUMENTS[3]}
  Run Keyword If  '${ARGUMENTS[2]}' == 'budget.description'  Input text  id=planform-title  ${ARGUMENTS[3]}
  Run Keyword If  '${ARGUMENTS[2]}' == 'items[0].deliveryDate.endDateitem'
  ...  PlanUpdateItemDeliveryEndDate  \#collapseItems .tab-content .tab-pane:first  ${ARGUMENTS[3]}
  Run Keyword If  '${ARGUMENTS[2]}' == 'items[0].quantity'  JsCollapseShowAndScroll  \#collapseItems
  Run Keyword If  '${ARGUMENTS[2]}' == 'items[0].quantity'  JsTabShowAndScroll  \#collapseItems .nav li:first a
  Run Keyword If  '${ARGUMENTS[2]}' == 'items[0].quantity'
  ...  PlanUpdateItemQuantity  \#collapseItems .tab-content .tab-pane:first  ${ARGUMENTS[3]}
  PlanUpdateSave

Додати предмет закупівлі в план
  [Arguments]  ${username}  ${uaid}  ${item_data}

  PlanFormOpenByUAID  ${uaid}
  InputPlanOneItem  ${item_data}
  PlanUpdateSave

Видалити предмет закупівлі плану
  [Arguments]  ${username}  ${uaid}  ${item_key}

  PlanFormOpenByUAID  ${uaid}
  JsCollapseShowAndScroll  \#collapseItems
  Click Element   jquery=#collapseItems .nav li[data-title^='${item_key}']
  Sleep  1
  Click Element   jquery=#collapseItems .nav li[data-title^='${item_key}'] .js-dynamic-form-remove
  Wait Until Page Contains   Ви впевнені що бажаєте видали обрану номенклатуру?   10
  Click Element   xpath=//div[contains(@class, 'jconfirm-box')]//button[contains(@class, 'btn btn-default waves-effect waves-light btn-lg')]
  PlanUpdateSave

Отримати інформацію із плану
  [Arguments]  ${username}  ${uaid}  ${key}
  ${item0Wrapper}=  Set Variable  \#accordionItems .panel:nth(0) .panel-collapse:first
  ${item1Wrapper}=  Set Variable  \#accordionItems .panel:nth(1) .panel-collapse:first
  ${budget}=  get_invisible_text  jquery=#general-info .budget-amount

  PlanOpenByUAID  ${uaid}
  JsSetScrollToElementBySelector  \#general-info
  Run Keyword And Return If   '${key}' == 'tender.procurementMethodType'  get_invisible_text  jquery=#general-info .procurement-method-type
  Run Keyword And Return If   '${key}' == 'budget.amount'   Convert To Number  ${budget}
  Run Keyword And Return If   '${key}' == 'budget.description'   get_text  jquery=#general-info .budget-description .value
  Run Keyword And Return If   '${key}' == 'budget.currency'   get_invisible_text  jquery=#general-info .budget-currency
  Run Keyword And Return If   '${key}' == 'budget.id'   get_text  jquery=#general-info .budget-id .value
  Run Keyword And Return If   '${key}' == 'budget.project.id'   get_invisible_text  jquery=#general-info .budget-project-id
  Run Keyword And Return If   '${key}' == 'budget.project.name'   get_invisible_text  jquery=#general-info .budget-project-name
  Run Keyword And Return If   '${key}' == 'classification.description'   get_invisible_text  jquery=#general-info .main-classification-description
  Run Keyword And Return If   '${key}' == 'classification.scheme'   get_invisible_text  jquery=#general-info .main-classification-scheme
  Run Keyword And Return If   '${key}' == 'classification.id'   get_invisible_text  jquery=#general-info .main-classification-code
  Run Keyword And Return If   '${key}' == 'tender.tenderPeriod.startDate'   get_invisible_text  jquery=#general-info .tender-start-date-source
  ${procuringEntityNeedToBeVisible}=  Run Keyword And Return Status  Should Start With  ${key}  procuringEntity
  Run Keyword If   ${procuringEntityNeedToBeVisible}  JsSetScrollToElementBySelector  \#procuring-entity-info
  Run Keyword And Return If   '${key}' == 'procuringEntity.name'   get_invisible_text  jquery=#procuring-entity-info .name
  Run Keyword And Return If   '${key}' == 'procuringEntity.identifier.scheme'   get_invisible_text  jquery=#procuring-entity-info .identifier-scheme
  Run Keyword And Return If   '${key}' == 'procuringEntity.identifier.id'   get_invisible_text  jquery=#procuring-entity-info .identifier-code
  Run Keyword And Return If   '${key}' == 'procuringEntity.identifier.legalName'   get_text  jquery=#procuring-entity-info .legal-name .value
  ${item0NeedToBeVisible}=  Run Keyword And Return Status  Should Start With  ${key}  items[0]
  Run Keyword If   ${item0NeedToBeVisible}    JsCollapseShowAndScroll  ${item0Wrapper}
  Run Keyword And Return If   '${key}' == 'items[0].description'    get_text  jquery=${item0Wrapper} .item-info-wrapper .title .value
  Run Keyword And Return If   '${key}' == 'items[0].quantity'    Get invisible text number by locator  jquery=${item0Wrapper} .item-info-wrapper .quantity-source
  Run Keyword And Return If   '${key}' == 'items[0].deliveryDate.endDate'    get_invisible_text  jquery=${item0Wrapper} .item-info-wrapper .delivery-end-date-source
  Run Keyword And Return If   '${key}' == 'items[0].unit.code'   get_invisible_text  jquery=${item0Wrapper} .item-info-wrapper .unit-code-source
  Run Keyword And Return If   '${key}' == 'items[0].unit.name'   get_invisible_text  jquery=${item0Wrapper} .item-info-wrapper .unit-title-source
  Run Keyword And Return If   '${key}' == 'items[0].classification.description'    get_invisible_text  jquery=${item0Wrapper} .item-info-wrapper .main-classification-description
  Run Keyword And Return If   '${key}' == 'items[0].classification.scheme'    get_invisible_text  jquery=${item0Wrapper} .item-info-wrapper .main-classification-scheme
  Run Keyword And Return If   '${key}' == 'items[0].classification.id'    get_invisible_text  jquery=${item0Wrapper} .item-info-wrapper .main-classification-code
  ${item1NeedToBeVisible}=  Run Keyword And Return Status  Should Start With  ${key}  items[1]
  Run Keyword If   ${item1NeedToBeVisible}    JsCollapseShowAndScroll  ${item1Wrapper}
  Run Keyword And Return If   '${key}' == 'items[1].description'    get_text  jquery=${item1Wrapper} .item-info-wrapper .title .value
  Run Keyword And Return If   '${key}' == 'items[1].quantity'    Get invisible text number by locator  jquery=${item1Wrapper} .item-info-wrapper .quantity-source
  Run Keyword And Return If   '${key}' == 'items[1].deliveryDate.endDate'    get_invisible_text  jquery=${item1Wrapper} .item-info-wrapper .delivery-end-date-source
  Run Keyword And Return If   '${key}' == 'items[1].unit.code'   get_invisible_text  jquery=${item1Wrapper} .item-info-wrapper .unit-code-source
  Run Keyword And Return If   '${key}' == 'items[1].unit.name'   get_invisible_text  jquery=${item1Wrapper} .item-info-wrapper .unit-title-source
  Run Keyword And Return If   '${key}' == 'items[1].classification.description'    get_invisible_text  jquery=${item1Wrapper} .item-info-wrapper .main-classification-description
  Run Keyword And Return If   '${key}' == 'items[1].classification.scheme'    get_invisible_text  jquery=${item1Wrapper} .item-info-wrapper .main-classification-scheme
  Run Keyword And Return If   '${key}' == 'items[1].classification.id'    get_invisible_text  jquery=${item1Wrapper} .item-info-wrapper .main-classification-code
  Fail  NotImplemented

### EOF - PLANNING ###

### BOF - HELPERS ###

UserChangeOrgnizationInfo
  [Arguments]  ${data}
  ${keys}=  Get Dictionary Keys  ${data}

  Go To  ${BROKERS['pzo'].basepage}/user/profile
  Wait Until Page Contains  Інформація про компанію   10
  Sleep  1

  Run Keyword If  'name' in ${keys}  Input text  id=profileform-organization_name  ${data.name}
  Run Keyword If  'identifier' in ${keys}  Input text  id=profileform-organization_edrpou  ${data.identifier.id}
  Run Keyword If  'address' in ${keys}  JsSetScrollToElementBySelector  \#profileform-organization_region_id
  Run Keyword If  'address' in ${keys}  Select From List By Label  jquery=#profileform-organization_region_id  ${data.address.region}
  Run Keyword If  'address' in ${keys}  Input Text  jquery=#profileform-organization_postal_code  ${data.address.postalCode}
  Run Keyword If  'address' in ${keys}  Input Text  jquery=#profileform-organization_locality  ${data.address.locality}
  Run Keyword If  'address' in ${keys}  Input Text  jquery=#profileform-organization_street_address  ${data.address.streetAddress}

  JsSetScrollToElementBySelector  \#user-profile-form .js-submit-btn
  Click Element   jquery=\#user-profile-form .js-submit-btn
  Sleep  1
  Wait Until Page Contains   Контактна інформація успішно оновлена   10
  Click Element   xpath=//div[contains(@class, 'jconfirm-box')]//button[contains(@class, 'btn btn-default waves-effect waves-light btn-lg')]

InputClassificationByWrapper
  [Arguments]  ${wrapper}  ${classification_id}

  Click Element                      jquery=${wrapper} a[href='#classification']
  Wait Until Element Is Visible      xpath=//div[contains(@id, 'classification-modal')]//h4[contains(@id, 'classificationModalLabel')]
  Sleep  1
  Input text                         xpath=//div[contains(@id, 'classification-modal')]//input[@class='form-control js-input']  ${classification_id}
  Press key                          xpath=//div[contains(@id, 'classification-modal')]//input[@class='form-control js-input']  \\13
  Sleep  1
  Wait Until Page Contains Element   xpath=//div[contains(@id, 'classification-modal')]//strong[contains(., '${classification_id}')]  20
  Click Element                      xpath=//div[contains(@id, 'classification-modal')]//i[@class='jstree-icon jstree-checkbox']
  Click Element                      xpath=//div[contains(@id, 'classification-modal')]//button[contains(@class, 'btn btn-default waves-effect waves-light js-submit')]
  Sleep  1

InputAdditionalClassificationsByWrapper
  [Arguments]  ${wrapper}  ${additionalClassifications}

  Click Element  jquery=${wrapper} a[href='#additionalclassification']
  Wait Until Element Is Visible  xpath=//div[contains(@id, 'additional-classification-modal')]//h4[contains(@id, 'additionalClassificationModalLabel')]
  Sleep  1

  ${count}=  Get Length  ${additionalClassifications}
  : FOR    ${INDEX}    IN RANGE    0    ${count}
  \   Continue For Loop If  '${additionalClassifications[${INDEX}].scheme}' == 'ДКПП'
  \   Click Element  jquery=#additional-classification-modal .nav a[data-toggle="tab"][data-scheme="${additionalClassifications[${INDEX}].scheme}"]
  \   Wait Until Element Is Visible  jquery=#additional-classification-modal .tab-pane.tree-wrapper.active input.js-input
  \   Input text     jquery=#additional-classification-modal .tab-pane.tree-wrapper.active input.js-input  ${additionalClassifications[${INDEX}].id}
  \   Press key      jquery=#additional-classification-modal .tab-pane.tree-wrapper.active input.js-input  \\13
  \   Sleep  2
  \   Wait Until Page Contains Element   jquery=#additional-classification-modal .tab-pane.tree-wrapper.active .tree.js-search-tree strong:contains("${additionalClassifications[${INDEX}].id}")  20
  \   Click Element  jquery=#additional-classification-modal .tab-pane.tree-wrapper.active .tree.js-search-tree li:first i.jstree-checkbox

  Click Element  xpath=//div[contains(@id, 'additional-classification-modal')]//button[contains(@class, 'js-submit')]
  Sleep  1

InputPlanItems
  [Arguments]  ${data}
  ${items}=  Get From Dictionary   ${data}  items
  ${count}=  Get Length  ${items}

  : FOR    ${INDEX}    IN RANGE    0    ${count}
  \   InputPlanOneItem  ${items[${INDEX}]}

InputPlanOneItem
  [Arguments]  ${data}
  ${wrapper}=  Set Variable  \#collapseItems .tab-content .tab-pane.active
  ${keys}=  Get Dictionary Keys  ${data}

  JsCollapseShowAndScroll  \#collapseItems
  Click Element  jquery=#collapseItems a[href="#add-items"]
  Sleep  2
  Input text  jquery=${wrapper} [id$='-description']  ${data.description}
  PlanUpdateItemQuantity  ${wrapper}  ${data.quantity}
  JsSetScrollToElementBySelector  ${wrapper} [id$='-unit_id']
  Select From List By Label  jquery=${wrapper} [id$='-unit_id']  ${data.unit.name}
  InputClassificationByWrapper  ${wrapper}  ${data.classification.id}
  Run Keyword If  'additionalClassifications' in ${keys}
  ...  InputAdditionalClassificationsByWrapper  ${wrapper}  ${data.additionalClassifications}
  PlanUpdateItemDeliveryEndDate  ${wrapper}  ${data.deliveryDate.endDate}

TenderOpenByUAID
  [Arguments]  ${uaid}

  Go To  ${BROKERS['pzo'].basepage}/tender/${uaid}
  Wait Until Page Contains    Закупівля ${uaid}    10

TenderFormOpenByUAID
  [Arguments]  ${uaid}

    TenderOpenByUAID  ${uaid}
    Click Element  xpath=//a[contains(@href, '/tender/update')][1]
    sleep    1
    wait until page contains element    id=tender-form    10
    Sleep  1

PlanOpenByUAID
  [Arguments]  ${uaid}

  Go To  ${BROKERS['pzo'].basepage}/plan/${uaid}
  Wait Until Page Contains    План ${uaid}    10

PlanFormOpenByUAID
  [Arguments]  ${uaid}

  PlanOpenByUAID  ${uaid}
  Click Element  xpath=//a[contains(@href, '/plan/update')][1]
  Wait Until Page Contains  Редагування   10
  Sleep  1

PlanUpdateItemQuantity
  [Arguments]  ${wrapper}  ${quantity}
  ${quantity_srt}=  Convert To String  ${quantity}

  JsSetScrollToElementBySelector  ${wrapper} [id$='-quantity']
  Input text  jquery=${wrapper} [id$='-quantity']  ${quantity_srt}

PlanUpdateItemDeliveryEndDate
  [Arguments]  ${wrapper}  ${delivery_end_date}
  ${date}=  convert_isodate_to_site_datetime  ${delivery_end_date}

  JsInputHiddenText  ${wrapper} [id$='-delivery_end_date']  ${date}

PlanUpdateSave

  JsSetScrollToElementBySelector  \#submitBtn
  Click Element   xpath=//*[@id='submitBtn']
  Sleep  1
  Wait Until Page Contains   План оновлений, дочекайтесь опублікування на сайті уповноваженого органу.   10
  Click Element   xpath=//div[contains(@class, 'jconfirm-box')]//button[contains(@class, 'btn btn-default waves-effect waves-light btn-lg')]
  Wait For Sync Tender  60

JsInputHiddenText
  [Arguments]  ${selector}  ${text}

  Execute JavaScript  jQuery("${selector}").val("${text}");

JsSetScrollToElementBySelector
  [Arguments]  ${selector}

  Execute JavaScript  scrollToElement("${selector}", 0, 10);
  Sleep  100ms

JsCollapseShowAndScroll
  [Arguments]  ${selector}

  Execute JavaScript  jQuery("${selector}").collapse("show");
  Sleep  500ms
  JsSetScrollToElementBySelector  ${selector}

JsTabShowAndScroll
  [Arguments]  ${selector}

  Execute JavaScript  jQuery("${selector}").tab("show");
  Sleep  300ms
  JsSetScrollToElementBySelector  ${selector}

GetDictionaryKeyExist           [Arguments]     ${Dictionary Name}      ${Key}
  Run Keyword And Return Status       Dictionary Should Contain Key       ${Dictionary Name}      ${Key}

GetValueFromDictionaryByKey      [Arguments]     ${Dictionary Name}      ${Key}
  ${KeyIsPresent}=    Run Keyword And Return Status       Dictionary Should Contain Key       ${Dictionary Name}      ${Key}
  ${Value}=           Run Keyword If      ${KeyIsPresent}     Get From Dictionary             ${Dictionary Name}      ${Key}
  Return From Keyword         ${Value}

GenerateFakeDocument
  ${file_path}  ${file_name}  ${file_content}=  op_robot_tests.tests_files.service_keywords.Create Fake Doc
  [return]  ${file_path}

GenerateFakeText
  ${text}= Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
  [return] ${text}

WaitPageSyncing
  [Arguments]  ${timeout}
  ${passed}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  ${timeout} s  3 s  GetPageSyncingStatus
  Run Keyword Unless  ${passed}  Fatal Error  Sync Finish not finish in ${timeout} sec

GetPageSyncingStatus
  Sleep  2
  Reload Page
  Sleep  1
  Page Should Not Contain Element  jquery=.wrapper .card-box .fa.fa-refresh

WaitTenderAuctionEnd
  [Arguments]  ${timeout}
  ${passed}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  ${timeout} s  0 s  GetTenderAuctionEndStatus
  Run Keyword Unless  ${passed}  Fatal Error  Tender not changed status from active.auction in ${timeout} sec

GetTenderAuctionEndStatus
  ${tenderStatus}=  get_invisible_text  xpath=//*[contains(@class, 'hidden opstatus')]
  return from keyword if  Should Not Be Equal As Strings  ${tenderStatus}  active.auction
  Sleep  60
  Reload Page
  Sleep  5
  ${tenderStatus}=  get_invisible_text  xpath=//*[contains(@class, 'hidden opstatus')]
  Should Not Be Equal As Strings  ${tenderStatus}  active.auction

Input Float
  [Arguments]  ${input_jquery_selector}  ${value}
  ${value}=          convert_float_to_string  ${value}
  Input Text  jquery=${input_jquery_selector}  ${value}

Input Float Multiply100
  [Arguments]  ${input_jquery_selector}  ${value}
  ${value}=  multiply_hundred  ${value}
  Input Float  ${input_jquery_selector}  ${value}

Input DateTime
  [Arguments]  ${input_jquery_selector}  ${date}
  ${date}=  convert_datetime_for_delivery  ${date}
  ${date}=  Convert Date  ${date}  %d.%m.%Y %H:%M
  Input Text  jquery=${input_jquery_selector}  ${date}

Input DateTime XPath
  [Arguments]  ${input_selector}  ${date}
  ${date}=  convert_datetime_for_delivery  ${date}
  ${date}=  Convert Date  ${date}  %d.%m.%Y %H:%M
  Input Text  xpath=//${input_selector}  ${date}

Input Converted DateTime
  [Arguments]  ${input_jquery_selector}  ${date}
  Input Text  jquery=${input_jquery_selector}  ${date}
  sleep    1s
  execute javascript    $("${input_jquery_selector}").blur();
  sleep    100ms

Input Text With Checking Input Isset
  [Arguments]  ${input_jquery_selector}  ${text}
  Log  ${input_jquery_selector}
  ${input_isset}=  Run Keyword And Return Status  Page Should Contain Element  jquery=${input_jquery_selector}
  Run Keyword If  ${input_isset}  Input Text  jquery=${input_jquery_selector}  ${text}

Input Text With Checking Input Isset XPath
  [Arguments]  ${input_selector}  ${text}
  Log  ${input_selector}
  ${input_isset}=  Run Keyword And Return Status  Page Should Contain Element  xpath=//${input_selector}
  Run Keyword If  ${input_isset}  Input Text  xpath=//${input_selector}  ${text}

Select From List By Label With Checking Input Isset XPath
  [Arguments]  ${input_selector}  ${text}
  Log  ${input_selector}
  ${input_isset}=  Run Keyword And Return Status  Page Should Contain Element  xpath=//${input_selector}
  Run Keyword If  ${input_isset}  Select From List By Label  xpath=//${input_selector}  ${text}

GetInputProcTypeByProcurementMethodType
  [Arguments]  ${procurementMethodType}
  ${pzo_proc_type}=  Convert_to_Lowercase  ${procurementMethodType}
  ${pzo_proc_type}=  Remove String  ${pzo_proc_type}  \.
  ${pzo_proc_type}=  Set Variable If  '${pzo_proc_type}' == 'belowthreshold'  ${EMPTY}  ${pzo_proc_type}
  [return]  ${pzo_proc_type}

### EOF - HELPERS ###
