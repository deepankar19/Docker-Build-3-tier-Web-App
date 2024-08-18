"use strict";

/**
 * This function display a Contact on the Page
 * as a LI in the UL Element.
 * 
 * @param contact An instance of a Contact Object
 * @param indx    Index of Contact from the contacts Array - used for Element IDs
 */
function addContact(contact, indx) {
    $('#contactsList')
    .append(
        $('<li>')
        .append(
            $('<a>')
            .attr('href', `mailto:${contact.email}`)
            .text(contact.name)
        )
        .append(
            $('<span>')
            .attr('id', `cell_${indx}`)
            .attr('class', 'hidden')
            .text(`: ${contact.cell}`)
        )
        .append(
            $('<span>')
            .attr('id', `alert_${indx}`)
            .attr('class', 'alert')
            .text(' show cell')
            .click(() => {
                $(`#alert_${indx}`).hide();
                $(`#cell_${indx}`).show();
            })
        )
    );
}


/**
 * This function traverses teh Array of Contacts passed in,
 * instantiates an Instance of a Contact for each contact in the file, 
 * then sends it to the addContact() function for display.
 * 
 * @param contacts  Array of Contacts
 */
function processData(contacts) {
    contacts.forEach((contact, indx) => {
        let contactName = contact.name;
        let contactEmail = contact.email;
        let contactCell = contact.cell;
        
        // Create new Contact
        const newContact = new Contact(contactName, contactEmail, contactCell);
        // Add Contact to List (pass contact instance and current element index in Array)
        addContact(newContact, indx);
    });
}

// Start Processing
$( document ).ready(() => {
    $.getJSON('http://localhost:3000/', contacts => {
        console.log(contacts);
        processData(contacts);
    });
});