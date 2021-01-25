local function completeFile( shell, nIndex, sText, tPreviousText )
    if nIndex == 1 then
        return fs.complete( sText, shell.dir(), true, false )
    end
end

local function completeDir( shell, nIndex, sText, tPreviousText )
    if nIndex == 1 then
        return fs.complete( sText, shell.dir(), false, true )
    end
end

local function completeEitherEither( shell, nIndex, sText, tPreviousText )
    if nIndex == 1 then
        local tResults = fs.complete( sText, shell.dir(), true, true )
        for n=1,#tResults do
            local sResult = tResults[n]
            if string.sub( sResult, #sResult, #sResult ) ~= "/" then
                tResults[n] = sResult .. " "
            end
        end
        return tResults
    elseif nIndex == 2 then
        return fs.complete( sText, shell.dir(), true, true )
    end
end

sPath = shell.path()
sPath = sPath..":/oculusos/programs"
if http then
	sPath = sPath..":/oculusos/programs/http"
end
shell.setPath( sPath )

shell.setCompletionFunction( "oculusos/programs/cat", completeFile )
shell.setCompletionFunction( "oculusos/programs/touch", completeEitherEither )
