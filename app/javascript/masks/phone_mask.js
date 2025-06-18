import Inputmask from "inputmask";

document.addEventListener("turbo:load", function () {
  const phoneInput = document.querySelector("#user_phone");
  if (phoneInput) {
    Inputmask("+375 (99) 999-99-99").mask(phoneInput);
  }
});
