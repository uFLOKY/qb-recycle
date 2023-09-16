window.addEventListener('message', function(event){
    if(event.data.action == "show"){
        document.getElementById("casino-text").innerHTML = event.data.text;
        document.getElementById("casino-container").classList.remove("fadeOut");
        document.getElementById("casino-container").classList.add("fadeIn");
    } else if(event.data.action == "hide"){
        document.getElementById("casino-container").classList.remove("fadeIn");
        document.getElementById("casino-container").classList.add("fadeOut");
    }
});