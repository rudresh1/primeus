*** Settings ***
Documentation    Custom Keywords for Logpoint
Library    String
Library    SeleniumLibrary    
Library    OperatingSystem 
Resource    PageObject.robot
Resource    Shoulder.robot

*** Variable ***
${testsRootFolder}    ${EXECDIR}/test/driver/
@{criticalHxFieldList}    Clinical Hx (Referral)    Hx from patient    Surgical Hx    Comparison    Specific ROI    Scan quality    Side selection
@{findingList}    Liver    Portal vein    Gallbladder    CBD    Pancreas    Spleen   Right kidney    Left kidney    Aorta    Free fluid    Lymph nodes    RIF    LIF    Other findings
@{commentList}    Comment   Further APT    Follow up    COMMENT (_side_)
    
*** Keywords ***

Fill US Abdominal Form
    [Arguments]    ${member}
    Run keyword if  'GeneralDetails' in @{member}    Fill The General Information Form    ${member['GeneralDetails']}
    Run keyword if  'clinicalHx' in @{member}    Fill Clinical Hx In Abdominal    ${member}[clinicalHx]
    Run keyword if  'findings' in @{member}    Fill Findings in Abdominal    ${member}[findings]
    Run keyword if  'comments' in @{member}    Fill Comment in Adbominal    ${member}[comments]

Fill The List Of Fields
    [Arguments]    ${member}    ${fieldList}
    FOR    ${key}    IN    @{fieldList.keys()}
        ${value}=    Get From Dictionary    ${fieldList}    ${key}
        Run keyword if  '${value}' in @{member}    ${key}     ${member}[${value}]
    END

    
New Fill The List Of Fields
    [Arguments]    ${member}    ${fieldList}
    sleep     2
    FOR    ${key}    IN    @{fieldList}
        Log    ${key}    console=yes
        ${keyList}    Get Dictionary Keys    ${member} 
        ${found}    Evaluate    '${key}' in @{keyList}    
        Log    ${found}    console=yes   
        Run keyword if  '${key}' in @{keyList}    ${key}     ${member}[${key}]
    END

Fill The General Information Form
    [Documentation]    Filling the form for the abdominal US
    [Arguments]     ${genMember}
    Log    Filling General Information From    DEBUG    console=yes
    Log    testinggggggggg    
    # Log    ${genMember['allField']['generalInfo']['DOB']}       
    ${first_Name}    Generate Random String    8
    ${last_Name}    Generate Random String    12
    ${patientid}    Generate random string    8    0123456789
    ${accessid}    Generate random string    8    0123456789
    ${site}    Generate Random String    3   
    ${room}    Generate Random String    3 
    Input Text    //input[@type='text'][@placeholder='First Name']   ${first_Name}
    Input Text    //input[@type='text'][@placeholder='Last Name']   ${last_Name}
    Input Text    id=date-of-birth    ${genMember['DOB']}
    Input Text    id =patientID      ${patientid}
    Input Text    id=accessionNo    ${accessid}
    Input Text    id=site-name   ${genMember['site-name']}_${site} 
    Input Text    id=modality-name    ${room}
    
    Click Element    //label[./input[@name='gender_state']]/span[text()='${genMember['gender']}']       
    
Fill The General Information
    [Arguments]     ${genMember}
    Fill Template Data    ${genMember}[templateType]    generalInfo


Fill Clinical Hx In Abdominal
    [Documentation]     Filling the form for clinical hx
    [Arguments]    ${clinMember}
    Log   clinMember= ${clinMember}        console=yes
    &{oldFieldList}    Create Dictionary    Clinical Hx (Referral)=referral    Hx from Patient=hxFromPatient    Surgical Hx=surgicalHx    Comparison=comparison
    ...    Specific ROI=specificRoi    Scan Quality=ScanQuality     Side selection=sideSelection   
    Run keyword if  'templateType' in @{clinMember}    Run Keywords    
    ...    Fill Template Data    ${clinMember}[templateType]    clinicalHx
    ...    AND
    ...    Log   clinicalHx= ${clinMember}[templateType]        console=yes
    ...    ELSE    Fill The List Of Fields    ${clinMember}    ${oldFieldList}

Fill Findings in Abdominal 
    [Documentation]     Filling the findings for findings
    [Arguments]    ${findMember}
    Log   =========== Findings ===========    console=yes
      &{oldFieldList}    Create Dictionary    Liver=liver    Portal vein=portalVein    Gallbladder=gallbladder    CBD=cbd    Pancreas=pancreas
      ...   Spleen=spleen   Right Kidney=rightkidney    Left Kidney=leftkidney    Aorta=aorta    Free Fluid=freefluid    Lymph nodes=lymphnodes    Rif=rif       
      ...    Lif=lif    Other Findings=otherfindings
      
    Run keyword if  'templateType' in @{findMember}
    ...    Fill Template Data    ${findMember}[templateType]    findings
    ...    ELSE    Fill The List Of Fields    ${findMember}    ${oldFieldList}
  

Fill Comment in Adbominal
    [Documentation]     Filling the comment for clinical hx
    [Arguments]         ${conMember}
    Log   =========== Findings ===========    console=yes
    &{oldFieldList}    Create Dictionary    Comment=comment   Further APT=furtherapt    Follow up=followup    'COMMENT (_side_)=comment(_side_)
    
    Run keyword if  'templateType' in @{conMember}
    ...    Fill Template Data    ${conMember}[templateType]    comment
    ...    ELSE    Fill The List Of Fields    ${conMember}    ${oldFieldList}


Clinical Hx (Referral)
    [Documentation]    selecting the options of clinical hx
    [Arguments]        ${textArea}=${EMPTY}
    Enter Text On Field    Clinical Hx (Referral)    ${textArea}
    
Hx from Patient
    [Documentation]      selecting the options of hx
    [Arguments]    ${data}
    Select Value For Field    Hx from patient        ${data}[option]
    Run Keyword If    '${data}[option]'=='Yes'
    ...    Enter Text On Field    Hx from patient    ${data}[textArea]
    
Surgical Hx
    [Documentation]    selecting the options of Surgical hx
    [Arguments]        ${data}
    Select Value For Field    Surgical Hx        ${data}[option]
    Run Keyword If    '${data}[option]'=='Yes'    Run Keywords
    ...    Run Keyword If    '${data}[dropdownOptions]'!='${EMPTY}'    Select Dropdown By Text    Surgical Hx    --choose--    ${data}[dropdownOptions]
    ...    AND    Run Keyword If    '${data}[textArea]'!='${EMPTY}'    Enter Text On Field    Surgical Hx    ${data}[textArea]
     
Comparison
    [Documentation]    selecting the options of Comparison
    [Arguments]    ${data}    ${date}=${EMPTY}
    Select Value For Field    Comparison    ${data}[option]
    Run Keyword If    '${data}[option]'=='Yes'    Run Keywords
    ...    Run Keyword If    '${data}[modalityOptions]'!='${EMPTY}'    Select Dropdown By Text    Comparison    ---Modality---    ${data}[modalityOptions]
    ...    AND    Run Keyword If    '${data}[providerOptions]'!='${EMPTY}'    Select Dropdown By Text    Comparison    ---Provider---    ${data}[providerOptions]
    ...    AND    Run Keyword If    '${data}[subField]'!='${EMPTY}'    Select Value For Field    Comparison    ${data}[subField]
    ...    AND    Run Keyword If    '${data}[subField]'=='Date' and '${date}'=='${EMPTY}'     Enter Date In Sub-Field    Comparison    ${data}[date]
    ...    AND    Run Keyword If    '${data}[subField]'=='Date' and '${date}'!='${EMPTY}'     Enter Date In Sub-Field    Comparison    ${date}
    ...    AND    Run Keyword If    '${data}[textArea]'!='${EMPTY}'    Enter Text On Field    Comparison    ${data}[textArea]

Specific ROI
    [Documentation]    selecting the options of Specific ROI
    [Arguments]    ${data}    ${dropdownOptions}=${EMPTY}    ${textArea}=${EMPTY}
    Select Value For Field    Specific ROI        ${data}[option]
    Run Keyword If    '${data}[option]'=='Yes'    Run Keywords
    ...    Run Keyword If    '${data}[dropdownOptions]'!='${EMPTY}'    Select Dropdown By Text    Specific ROI    --choose--    ${data}[dropdownOptions]
    ...    AND    Run Keyword If    '${data}[textArea]'!='${EMPTY}'    Enter Text On Field    Specific ROI    ${data}[textArea]
    
Scan Quality
    [Documentation]    selecting the options of Scan Quality
    [Arguments]    ${data}    ${check}=true
    Select Value For Field    Scan quality    ${data}[option]
    Run Keyword If    '${data}[option]'=='Suboptimal'
    ...    Toggle Field And Their Corresponding Comment Section    Scan quality    ${data}[checkboxOptions]    ${check}

          
Toggle Field And Their Corresponding Comment Section
    [Arguments]    ${field}    ${detailList}    ${check}
    Log    ${field}    DEBUG    console=yes
    FOR    ${detail}    IN    @{detailList}
        Toggle Field    ${field}    ${detail}[checkboxName]    ${check}
        Run Keyword If    '${detail}[comments]'!='${EMPTY}'
        ...    Input Text    //tr[@note-structure='${field}']//label[./input[@value='${detail}[checkboxName]'] and contains(@class,'checkbox-styled')]//following-sibling::textarea    ${detail}[comments]
    END

Liver
    [Documentation]    selecting the options of Liver
    [Arguments]    ${data}=${EMPTY}
    sleep    1
    Scroll Element Into View    //table//td[text()='Liver']
    sleep    1
    Select Value For Field    Liver    ${data}[option]
    sleep    1
    Run keyword if  'checkboxOptions' in @{data}    Fill Comment Section    Liver    ${data}[checkboxOptions]
    sleep    1
    Run keyword if  'size' in @{data}    Enter Size In Sub-Field    Liver    ${data}[size]
    sleep    1
    Run keyword if  'nm' in @{data}    Toggle Field    Liver    NM    ${data}[nm]
    # Run Keyword If    '${data}[option]'!='N E' and '${size}'!='${EMPTY}'    Enter Size In Sub-Field    Liver    ${size}
    # Run Keyword If    '${data}[option]'!='N E' and '${isNM}'!='${EMPTY}'    Toggle Field    Liver    NM    ${isNM}
    #Run Keyword If    '${data}[option]'!='Comments'    Run Keyword
    #...    Run Keyword If    '${data}[option]'!='    Select Value Under Comment Section    Liver    ${data}[subOption]
 
Select Value Under Comment Section
    [Documentation]    Select option located inside comments field.\n
    ...    Example: Selecting of 'Smooth' by first clcking selcting 'comments' then 'Smooth' of 'Liver' section.
    [Arguments]    ${field}    ${data}
    Select Value For Field    ${field}    Comments
    FOR    ${subSection}    IN    ${data}
        Run Keyword If    '${subSection}[type]'!='required_Fixed'    Toggle Field    ${field}    ${subSection}[option]    true
        Run keyword If    '${subSection}[radioOption]'!='${EMPTY}'    Select Value For Field    ${field}    ${subSection}[radioOption]
        Run keyword If    '${subSection}[textArea]'!='${EMPTY}'    Select Value For Field    ${field}    ${subSection}[textArea]
    END

Portal vein
    [Documentation]    selecting the options of portal vein
    [Arguments]    ${data}
    Scroll Element Into View    //table//td[text()='Portal vein']
    Select Value For Field    Portal vein    ${data}[option]
    Run keyword if  'checkboxOptions' in @{data}    Fill Comment Section    Portal vein    ${data}[checkboxOptions]
    
    
Fill Comment Section
    [Arguments]    ${field}    ${data}
    FOR    ${fieldSection}    IN    @{data}
        ${locator}    Set Variable    //tr[@note-structure='${field}']//div[./label[./input[@value='${fieldSection}[checkboxName]'] and (contains(@class,'sec-red-class') or contains(@class,'active-radio'))]]
        # sleep    1
        Toggle Field    ${field}    ${fieldSection}[checkboxName]    True
        Log    ${fieldSection} commenthere     DEBUG    console=yes
        sleep    1
        Log     subcheck     DEBUG    console=yes
        Run keyword if  'subCheckboxName' in @{fieldSection}    Fill Sub Section    ${fieldSection}[option]    ${fieldSection}[subCheckboxName]
        # Run keyword if  'subCheckboxName' in @{fieldSection}    Run Keyword    Run Keyword If    '${fieldSection}[subCheckboxName]'=='NM'    Run Keywords    Scroll Element Into View    ${locator}//label[./input[@value='NM'] and contains(@class,'checkbox-styled')])[1]    AND    Click Element    ${locator}//label[./input[@value='NM'] and contains(@class,'checkbox-styled')])[1]
        # sleep    3
        Log     option     DEBUG    console=yes
        Log    ${locator}    console=yes
        Run keyword if  'option' in @{fieldSection}    Click Element    ${locator}//label[span[text()='${fieldSection}[option]']]
        # sleep    1
        Run keyword if  'option1' in @{fieldSection}    Click Element    ${locator}//label[span[text()='${fieldSection}[option1]']]
        # sleep    1
        Log     othersComment     DEBUG    console=yes
        Run keyword if  'othersComment' in @{fieldSection}    Input Text   ${locator}//textarea    ${fieldSection}[othersComment]
        # sleep    5
        Run keyword if  'cm/sec' in @{fieldSection}     Input Text   ${locator}//input[following-sibling::span[text()='cm/sec']]    ${fieldSection}[cm/sec]
        # sleep    1
        Log     textArea     DEBUG    console=yes
        Run keyword if  'textArea' in @{fieldSection}    Input Text    ${locator}//textarea    ${fieldSection}[textArea]
        # sleep    1
        Log     chooseOptions     DEBUG    console=yes
        Run Keyword If  'chooseOptions' in @{fieldSection}    Select Dropdown By Text    ${field}    --choose--    ${fieldSection}[chooseOptions]
        # sleep    1
        Log     inputBox     DEBUG    console=yes
        Run keyword if  'inputBox' in @{fieldSection}    Input Text    ${locator}//div[preceding::span[text()='${fieldSection}[inputBox][inputBoxName]']]/input[@name='rowText']    ${fieldSection}[inputBox][value]
        
        #Run keyword if    'type' in @{fieldSection}
        # ...    Run Keyword If    '${fieldSection}[type]'=='required_Fixed'     Run Keywords
        # ...    Log    Verify Requirerd field '${fieldSection}[checkboxName]' is Colored red and Mandatory.    DEBUG    console=yes
        #...    AND    Element Should Be Visible    //tr[@note-structure='${field}']//label[contains(@class,'sec-red-class')]/input[@value='${fieldSection}[checkboxName]' and contains(@class,'mandatory')]

    END


Fill Sub Section
    [Arguments]    ${field}    ${data}
    FOR    ${fieldSection}    IN    @{data}
        sleep    1
      
      
    END    
    # sleep     1    

Gallbladder
    [Documentation]    selecting the options of gall bladder
    [Arguments]    ${data}
    sleep    1
    Scroll Element Into View    //table//td[text()='Gallbladder']
    sleep    1
    Click Element    //table//td[text()='Gallbladder']
    sleep    1
    Select Value For Field    Gallbladder    ${data}[option]
    sleep    1
    Run keyword if  'checkboxOptions' in @{data}   Fill Comment Section    Gallbladder    ${data}[checkboxOptions]
    
CBD
    [Documentation]    selecting the options of CBD
    [Arguments]        ${data}
    Select Value For Field    CBD    ${data}[option]
    Run keyword if  'checkboxOptions' in @{data}   Fill Comment Section    CBD    ${data}[checkboxOptions]

    Run keyword if  'size' in @{data}    Enter Size In Sub-Field    CBD    ${data}[size]
    Run keyword if  'nm' in @{data}    Toggle Field    CBD    NM    ${data}[nm]

Pancreas
    [Documentation]    selecting the options of Pancreas
    [Arguments]    ${data}
    Select Value For Field    Pancreas    ${data}[option]
    Run keyword if  'checkboxOptions' in @{data}   Fill Comment Section    Pancreas    ${data}[checkboxOptions]

Spleen
    [Documentation]    selecting the options of spleen
    [Arguments]    ${data}
    Click Element    //table//td[text()='Spleen']
    Select Value For Field    Spleen    ${data}[option]
    Run keyword if  'checkboxOptions' in @{data}   Fill Comment Section    Spleen    ${data}[checkboxOptions]

    Run keyword if  'size' in @{data}    Enter Size In Sub-Field    Spleen    ${data}[size]
    Run keyword if  'nm' in @{data}    Toggle Field    Spleen    NM    ${data}[nm]

Right kidney
    [Documentation]    selecting the options of right kidney
    [Arguments]    ${data}
    Scroll Element Into View    //table//td[text()='Right kidney']
    Click Element    //table//td[text()='Right kidney']
    Select Value For Field    Right kidney    ${data}[option]
    Run keyword if  'checkboxOptions' in @{data}   Fill Comment Section    Right kidney    ${data}[checkboxOptions]

    Run keyword if  'size' in @{data}    Enter Size In Sub-Field    Right kidney    ${data}[size]
    Run keyword if  'nm' in @{data}    Toggle Field    Right kidney    NM    ${data}[nm]

Left kidney
    [Documentation]    selecting the options of left kidney
    [Arguments]        ${data}
    Scroll Element Into View    //table//td[text()='Left kidney']
    Select Value For Field    Left kidney    ${data}[option]
    Run keyword if  'checkboxOptions' in @{data}   Fill Comment Section    Left kidney    ${data}[checkboxOptions]

    Run keyword if  'size' in @{data}    Enter Size In Sub-Field    Left kidney    ${data}[size]
    Run keyword if  'nm' in @{data}    Toggle Field    Left kidney    NM    ${data}[nm]

Aorta
    [Documentation]    selecting the options of aorta
    [Arguments]    ${data}
    Select Value For Field    Aorta    ${data}[option]
    Run keyword if  'checkboxOptions' in @{data}    Fill Comment Section    Aorta    ${data}[checkboxOptions]
    
    Run keyword if  'size' in @{data}    Enter Size In Sub-Field    Aorta    ${data}[size]
    Run keyword if  'nm' in @{data}    Toggle Field    Aorta    NM    ${data}[nm]
Rif
    [Documentation]    selecting the options of rif
    [Arguments]    ${data}
    Select Value For Field    RIF    ${data}[option]
    Run Keyword If    'roi' in @{data}    Toggle Field    RIF    ROI    ${data}[roi]
    # Run keyword if  'ROI' in @{data}    Check Roi    RIF    ${data}[checkboxOptions]   
    Run keyword if  'checkboxOptions' in @{data}    Fill Comment Section    RIF    ${data}[checkboxOptions]
    #Run keyword if  'checkboxOptions' in @{data}    Check Roi    RIF    ${data}[checkboxOptions]

Lif
    [Documentation]    selecting the options of lif
    [Arguments]    ${data}
    Select Value For Field    LIF    ${data}[option]
    Run Keyword If    'roi' in @{data}    Toggle Field    LIF    ROI    ${data}[roi]
    # Run keyword if  'checkboxOptions' in @{data}    Check Roi    LIF    ${data}[checkboxOptions]    
    Run keyword if  'checkboxOptions' in @{data}    Fill Comment Section    LIF    ${data}[checkboxOptions]
    #Run keyword if  'checkboxOptions' in @{data}    Check Roi    LIF    ${data}[checkboxOptions]

Free Fluid
    [Documentation]    selecting the options of free fluid
    [Arguments]    ${data}
    Select Value For Field    Free fluid    ${data}[option]
    Run keyword if  'checkboxOptions' in @{data}    Fill Comment Section    Free fluid    ${data}[checkboxOptions]
   # Run Keyword If    '${subOptionList}'!='${EMPTY}' and '${subOptionList}'=='Suboptimal'
    #...    Toggle List Of Fields    Free fluid    ${subOptionList}    ${check}
    # Run Keyword If    '${subOptionList}'!='${EMPTY}' and '${subOptionList}'=='Suboptimal'
    # ...    Toggle List Of Fields    Free fluid    ${subOptionList}    ${check}


Lymph nodes
    [Documentation]    selecting the options of lymphnode
    [Arguments]    ${data}
    Select Value For Field    Lymph nodes    ${data}[option]
    Run Keyword If    'roi' in @{data}    Toggle Field    Lymph nodes    ROI    ${data}[roi]

Other Findings
    [Documentation]    selecting the options of Other findings
    [Arguments]    ${data}
    # Wait Until Element Is Visible    id=complete-screenshot    20
    sleep     20
    Select Value For Field    Other findings       ${data}[option]
    Run Keyword If    '${data}[option]'=='Comments'    Enter Text On Field    Other findings    ${data}[textArea]
    
Comment
    [Documentation]  selecting the options of comment
    [Arguments]    ${data}    
    Select Value For Field    COMMENT        ${data}[option]
    Run Keyword If    '${data}[option]'=='Comments'    Enter Text On Field    COMMENT    ${data}[textArea]

Further APT
    [Documentation]    selecting the options of Further APT
    [Arguments]        ${data}   
    Select Value For Field    Further APT    ${data}[option]
    Run keyword if  'checkboxOptions' in @{data}    Fill Comment Section    Further APT    ${data}[checkboxOptions]
   

Follow up
    [Documentation]    selecting the options of Follow up
    [Arguments]      ${data}    
    Select Value For Field    Follow up    ${data}[option] 
    Run Keyword If    '${data}[option]'=='Yes'    Enter Text On Field    Follow up    ${data}[textArea]


Click On Graphic Tab
    [Documentation]    selecting the graphic tab
    Wait Until Element Is Enabled    id:graphics-panel
    Click Element    id:graphics-panel

Click On Nothing To Indicate
    [Documentation]    selecting the nothing to indicate tab
    Click Element    id:nothingToIndicate

Click Confirm and Complete
    sleep    5
    Wait Until Page Does Not Contain Element    //div[@class='toast-message']    120
    Wait Until Element Is Visible    id=complete-screenshot    20
    Scroll Element Into View    id=complete-screenshot
   
    Click Using JavaScript    //input[@id='review-checkbox']    
    Click Element With Log Display    (//button[@id='complete-screenshot'])[last()]    Complete
    Wait Until Element Is Enabled    //div[@class='table-responsive']    120
    
Fill Template Data
    [Documentation]    Read template Json file and fill the form
    [Arguments]    ${templateType}    ${formType}
    ${pattern}    Split String    ${templateType}    _
    ${scenario}    Set Variable   ${pattern}[1]
    Log   templateType= ${templateType}    console=yes
    Log   scenario= ${pattern}[1]    console=yes
    Log    ${pattern[0]}     console=yes
     # ${templateData}=    Get Test Data With Filter    template/${pattern[0]}
     # ${data}    Set Variable   ${templateData}[${scenario}]
    # ${templateData}=    Get Test Data With Filter    template/${pattern[0]}    scenario    ${scenario}    
    ${templateData}=    Get Test Data With Filter    template/${pattern[0]}    scenario    ${scenario}
    sleep    5
    Log   templateData= ${templateData}    console=yes
    ${data}    Set Variable   ${templateData}[0]
    Log   templateData 0 = ${templateData}[0]    console=yes
    ${data}    Set Variable     ${data}[${scenario}]
    Log   data scenario = ${data}    console=yes
    Run Keyword If    '${formType}'=='generalInfo'    Fill The General Information Form    ${data}[generalInfo]    
    Run Keyword If    '${formType}'=='clinicalHx'    New Fill The List Of Fields    ${data}[clinicalHx]    ${criticalHxFieldList}    
    Run Keyword If    '${formType}'=='findings'    New Fill The List Of Fields    ${data}[findings]    ${findingList}
    Run Keyword If    '${formType}'=='comment'    New Fill The List Of Fields    ${data}[comment]    ${commentList}
    
