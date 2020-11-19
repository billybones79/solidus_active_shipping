// Shipments AJAX API


toggleUsedMethodEdit = function(){
    var link = $(this);
    link.parents('tbody').find('tr.edit-used-method').toggle();
    link.parents('tbody').find('tr.show-used-method').toggle();

    return false;
};

var toggleLabelEdit = function(event) {
    event.preventDefault();

    var link = $(this);
    link.parents('tbody').find('tr.edit-label').toggle();
    link.parents('tbody').find('tr.show-label').toggle();
};

var toggleNotesEdit = function(event) {
    event.preventDefault();

    var link = $(this);
    console.log(link);
    $("#add-admin-notes").find('div.edit-notes').toggle();
    $("#add-admin-notes").find('div.show-notes').toggle();
};

var toggleWeightEdit = function(event) {
    event.preventDefault();

    var link = $(this);
    link.parents('tbody').find('tr.edit-weight').toggle();
    link.parents('tbody').find('tr.show-weight').toggle();
};

var toggleWidthEdit = function(event) {
    event.preventDefault();

    var link = $(this);
    link.parents('tbody').find('tr.edit-width').toggle();
    link.parents('tbody').find('tr.show-width').toggle();
};

var toggleLengthEdit = function(event) {
    event.preventDefault();

    var link = $(this);
    link.parents('tbody').find('tr.edit-length').toggle();
    link.parents('tbody').find('tr.show-length').toggle();
};

var toggleHeightEdit = function(event) {
    event.preventDefault();

    var link = $(this);
    link.parents('tbody').find('tr.edit-height').toggle();
    link.parents('tbody').find('tr.show-height').toggle();
};

var toggleMethodEditDecorator = function(){
    var link = $(this);
    link.parents('tbody').find('tr.edit-method').toggle();
    link.parents('tbody').find('tr.show-method').toggle();


    return false;
};


$(document).ready(function () {
    'use strict';


    // handle ship click
    $('[data-hook=admin_shipment_form] a.ship_pws').on('click', function () {

        $(".alert-danger").remove();

        var link = $(this);
        var shipment_number = link.data('shipment-number');
        var url = Spree.url(Spree.routes.shipments_api + '/' + shipment_number + '/ship.json');
        $.ajax({
            type: 'PUT',
            url: url,
            data: {
                token: Spree.api_key
            }
        }).done(function () {
            window.location.reload();
        }).error(function (msg) {
            var response = "<div class='alert alert-danger alert'>"+msg.responseText+"</div>"
            $("#content").prepend(response);
        });
    });

    $('a.transmit').on('click', function () {

        $(".alert-danger").remove();

        Spree.routes.shipping_manifests_api = Spree.pathFor('api/pws_shipping_manifests');

        var link = $(this);
        var shipment_number = link.data('manifest-number');
        var url = Spree.url(Spree.routes.shipping_manifests_api + '/' + shipment_number + '/transmit.json');
        $.ajax({
            type: 'PUT',
            url: url,
            data: {
                token: Spree.api_key
            }
        }).done(function () {
            window.location.reload();
        }).error(function (msg) {
            window.location.reload();
            var response = "<div class='alert alert-danger alert'>"+msg.responseText+"</div>"
            $("#content").prepend(response);
        });
    });

    $('a.get-manifest').on('click', function () {

        $(".alert-danger").remove();

        Spree.routes.shipping_manifests_api = Spree.pathFor('api/pws_shipping_manifests')

        var link = $(this);
        var shipment_number = link.data('manifest-number');
        var url = Spree.url(Spree.routes.shipping_manifests_api + '/' + shipment_number + '/confirm.json');
        $.ajax({
            type: 'PUT',
            url: url,
            data: {
                token: Spree.api_key
            }
        }).done(function () {
            window.location.reload();
        }).error(function (msg) {
            window.location.reload();

            var response = "<div class='alert alert-danger alert'>"+msg.responseText+"</div>"
            $("#content").prepend(response);
        });
    });


});