Spree.ready(function(){
    $(".print-pdf").click(function(e){
        printJS({printable: $(e.target).data("url"), type:'pdf', showModal:true});
    })
})