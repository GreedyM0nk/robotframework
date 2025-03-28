*** Settings ***
Suite Setup       Some process    suite_process
Suite Teardown    Stop some process    suite_process
Test Setup        Restart Suite Process If Needed
Resource          process_resource.robot

*** Test Cases ***
Library namespace should be global
    Process Should Be Running    suite_process

Error in exit code and stderr output
    ${result}=    Run Python Process    1/0
    Result should match    ${result}    stderr=*ZeroDivisionError:*    rc=1

Change current working directory
    ${result1}=    Run Process    python    -c    import os; print(os.path.abspath(os.curdir))    cwd=.
    ${result2}=    Run Process    python    -c    import os; print(os.path.abspath(os.curdir))    cwd=${{pathlib.Path('..')}}
    Should Not Be Equal    ${result1.stdout}    ${result2.stdout}

Run process in shell
    ${result}=    Run Process    python -c "print('hello')"    shell=True
    Result should equal    ${result}    stdout=hello
    ${result}=    Run Process    python -c "print('hello')"    shell=joojoo
    Result should equal    ${result}    stdout=hello
    Run Keyword And Expect Error    *    Run Process    python -c "print('hello')"    shell=${False}
    Run Keyword And Expect Error    *    Run Process    python -c "print('hello')"    shell=${0}
    Run Keyword And Expect Error    *    Run Process    python -c "print('hello')"    shell=False
    Run Keyword And Expect Error    *    Run Process    python -c "print('hello')"    shell=false

Get process id
    ${handle}=    Some process
    ${pid}=    Get Process Id    ${handle}
    Should Not Be Equal   ${pid}   ${None}
    Evaluate    os.kill($pid, signal.SIGTERM) if hasattr(os, 'kill') else os.system('taskkill /pid ${pid} /f')
    Wait For Process    ${handle}

*** Keywords ***
Restart Suite Process If Needed
    ${alive}=    Is Process Running    suite_process
    Run Keyword Unless    ${alive}    Some process    suite_process
