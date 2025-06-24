import Inputmask from "inputmask";
document.addEventListener("DOMContentLoaded", () => {
  const phoneInput = document.getElementById("phone-input");
  if (phoneInput) {
    Inputmask("+375 (99) 999-99-99", {
      placeholder: "+375 (__) ___-__-__",
      showMaskOnHover: false,
      clearMaskOnLostFocus: false
    }).mask(phoneInput);
  }
});