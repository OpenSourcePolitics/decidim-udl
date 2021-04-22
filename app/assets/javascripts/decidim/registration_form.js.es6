$(document).ready(() => {
    const $provenanceFieldDiv = $("#registration_user_provenance_field")
    const $provenanceField = $("#registration_user_provenance")

    $("input[name='user[status]'][type='radio']").on("change", (checkedStatus) => {
        const $target = $(checkedStatus.currentTarget)

        if ($target.is(":checked") && !isInRestrictedList($target)) {
            displayOptionsFor($target.val())
            if ($provenanceFieldDiv.hasClass("hide") === true) {
                $provenanceFieldDiv.removeClass('hide')
            }
        } else {
            if ($provenanceFieldDiv.hasClass("hide") === false) {
                $provenanceFieldDiv.addClass('hide')
            }
        }
    })

    const isInRestrictedList = ($target) => {
        return $target.data("provenance") === false
    }

    const displayOptionsFor = (value) => {
        if (value === "teacher") {
            displayAllOptions()
        } else if (value === "personal") {
            displaySelectedOptions(value)
            displayBasicOptions()
        }  else if (value === "student") {
            displaySelectedOptions(value)
        }
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
});
