_PluginName = 'JM_Exec_Changer'
_VERSION = 'v1.1'

-- Creates an Executor with a GoTo Menue to change the Target Executor to a set of Executors

-- Created by Johannes Münch
-- Last updated Aug 11, 2023
-- E-Mail: maplugins@jmlutra.de


-------------------------------------------------------------------------------
--------------------------- DO NOT EDIT BELOW HERE! ---------------------------
-------------------------------------------------------------------------------

-- Systemvariables
Feed = gma.feedback
Cmd = gma.cmd
Gui = gma.gui
Obj = gma.show.getobj




function Main()
    Feed('\n***Executor Changer***\n\nVersion '.._VERSION..'\n\nCreated by Johannes Münch')
    gma.echo('***Executor Changer***\n\nVersion '.._VERSION..'\n\nCreated by Johannes Münch')
    Cmd('BlindEdit On')
    Cmd('ClearAll')

    local count = 0
    ::loopin::
    count = count + 1
    TargetExec = '0.0'
    SelectExec = '0.0'
    ChoiceExecs = { }
    TargetExec = GetUserInput('Target Executor Nr.'..count, 'Enter Target Executor {Page.Nr} [Enter when finished]')
    
    if TargetExec == nil then
        goto loopout
    end

    SelectExec = GetUserInput('Select Executor', 'Enter Select Executor {Page.Nr}')
    if SelectExec == nil then
        goto loopout
    end

    ChoiceExecs = SelectChoiceExecs()
    if ChoiceExecs == nil then
        goto loopout
    end
    BuildSelectExecutor()
    BuildCleanMacro()

    if not Gui.confirm('Executor Changer', 'The Executor '..TargetExec..' can be changed using the GoTo function of Executor '..SelectExec..'.\nThis Executor Changer can be deleted using the Clean '..TargetExec..' Macro.\n\nTo create more Executor Changers, just click ok.') then 
        goto loopout
    end
    goto loopin
    ::loopout::

end

function SelectChoiceExecs()
    local choiceExecs = { }
    local choiceExecsCount = 0
    local choiceExec = '0.0'
    local choiceExecsString = ''
    ::loopin::
    choiceExec = GetUserInput('Choice Executor', 'Enter Choice Executor {Page.Nr} [Enter when finished]')
    if choiceExec == nil then
        goto loopout
    end
    choiceExecsCount = choiceExecsCount + 1
    choiceExecs[choiceExecsCount] = choiceExec
    choiceExecsString = choiceExecsString .. choiceExec .. ', '
    goto loopin
    ::loopout::
    Feed('Choice Executors: '..choiceExecsString)
    return choiceExecs
end

function BuildSelectExecutor()
    for i=1, Tablelength(ChoiceExecs) do
        Cmd('Store Executor '..SelectExec..' Cue '..i)
        Cmd('Assign Executor '..SelectExec..' Cue '..i..' /cmd=\"Off Executor '..TargetExec..';  Copy Executor '..ChoiceExecs[i]..'  At '..TargetExec..' /o\"')
        Cmd('Label Executor '..SelectExec..' Cue '..i..' \"'..Obj.name(Obj.handle('Executor '..ChoiceExecs[i]))..'\"')
    end
    Cmd('Assign Goto ExecButton1 '..SelectExec)
    Cmd('Label Executor '..SelectExec..' \"Select Executor '..TargetExec..' Functions\"')
end

function BuildCleanMacro()
    local i = 1

    while gma.show.getobj.handle('Macro '..i) ~= nil do
        i = i + 1
    end

    CreateMacro(i, 'Clean '..TargetExec, {
        'Delete Executor '..TargetExec..' /nc',
        'Delete Executor '..SelectExec..' /nc',
        'Delete Macro 1.'..i..' /nc'
    })
end

function Cleanup()
    Cmd('ClearAll')
    Cmd('BlindEdit Off')
end

-- Utility Functions
function Tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

function CreateMacro (macroNum, label, macroLines)
    gma.cmd('Store Macro 1.'..macroNum)
    gma.cmd('Label Macro 1.'..macroNum..' \"'..label..'\"')

    for i = 1, Tablelength(macroLines) do
        gma.cmd('Store Macro 1.' .. macroNum .. '.' .. i)
        gma.cmd('Assign Macro 1.'..macroNum.."." .. i .. '/cmd=\"' .. macroLines[i] .. '\"')
    end
    gma.cmd('Assign Macro 1.'..macroNum..'.1 /info=\"'.._PluginName..'\"')
end

function GetUserInput (msg, placeholder)
    local userInput = gma.textinput(msg, placeholder)
    if userInput == placeholder then
        userInput = nil
    end
    return userInput
end

return Main,Cleanup;