$(document).ready(() => {
    const $provenanceFieldDiv = $("#registration_user_provenance_field")
    const $provenanceField = $("#registration_user_provenance")
    const $radioButtons = $("input[type='radio'][data-provenance=true]:checked")

    $("input[name='user[status]'][type='radio']").on("change", (checkedStatus) => {
        const $target = $(checkedStatus.currentTarget)

        if ($target.is(":checked") && !isInRestrictedList($target)) {
            displayOptionsFor($target.val())
            displayProvenanceField()
        } else {
            hideProvenanceField()
        }
        clearProvenanceField()
    })

    const isInRestrictedList = ($target) => {
        return $target.data("provenance") === false
    }

    const displayOptionsFor = (value) => {
        if (value === "personal") {
            displayAllOptions()
        } else if (value === "teacher") {
            displaySelectedOptions(value)
            displayBasicOptions()
        }  else if (value === "student") {
            displaySelectedOptions(value)
        }
    }

    const displayProvenanceField = () => {
        if ($provenanceFieldDiv.hasClass("hide") === true) {
            $provenanceFieldDiv.removeClass('hide')
        }
    }

    const hideProvenanceField = () => {
        if ($provenanceFieldDiv.hasClass("hide") === false) {
            $provenanceFieldDiv.addClass('hide')
        }
    }

    const clearProvenanceField = () => {
        $provenanceField.children('option:selected').removeAttr("selected")
        $provenanceField.val("")
    }

    const displayAllOptions = () => {
        $provenanceField.children("option").show()
    }

    const displaySelectedOptions = (value) => {
        $provenanceField.children(`option:not([data-status='${value}'])`).hide()
        $provenanceField.children(`option[data-status='${value}']`).show()
    }

    const displayBasicOptions = () => {
        $provenanceField.children("option[data-status='student']").show()
    }

    if ($radioButtons.length > 0) {
        displayOptionsFor($radioButtons.eq(0).val())
        displayProvenanceField()
    }
});
