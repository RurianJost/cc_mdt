function showSentence(sentence)
    SendNUIMessage({
        action = 'showSentence',
        data = {
            sentence = sentence
        }
    })
end

function hideSentence()
    SendNUIMessage({
        action = 'hideSentence',
        data = {}
    })
end
