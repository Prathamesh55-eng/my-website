function toggleTheme() {

    document.body.classList.toggle("light-mode");

    const themeButton = document.querySelector("nav button");

    if (document.body.classList.contains("light-mode")) {

        themeButton.textContent = "☀️";

        localStorage.setItem("theme", "light");

    } else {

        themeButton.textContent = "🌙";

        localStorage.setItem("theme", "dark");

    }
}


/* Load saved theme when the website opens */

window.addEventListener("DOMContentLoaded", function () {

    const savedTheme = localStorage.getItem("theme");

    const themeButton = document.querySelector("nav button");

    if (savedTheme === "light") {

        document.body.classList.add("light-mode");

        if (themeButton) {
            themeButton.textContent = "☀️";
        }

    } else {

        document.body.classList.remove("light-mode");

        if (themeButton) {
            themeButton.textContent = "🌙";
        }

    }

});