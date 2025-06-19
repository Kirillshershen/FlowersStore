document.addEventListener("DOMContentLoaded", function () {
  const searchInput = document.getElementById("product-search");
  const typeFilter = document.getElementById("product-type-filter");
  const productCheckboxes = document.querySelectorAll("#products-list .product-checkbox");
  const selectAllBtn = document.getElementById("select-all");
  const deselectAllBtn = document.getElementById("deselect-all");

  const discountTypeSelect = document.querySelector("#promotion_discount_type");
  const quantityFields = document.getElementById("quantity-promotions-fields");
  const container = document.getElementById("quantity-promotions-container");
  const addBtn = document.getElementById("add-quantity-promotion");
  const singleDiscountField = document.getElementById("promotion_discount_value");

  // --- Фильтрация продуктов ---
  function filterProducts() {
    const query = searchInput.value.toLowerCase();
    const selectedType = typeFilter.value;

    productCheckboxes.forEach(div => {
      const name = div.dataset.name;
      const type = div.dataset.type;

      const matchesName = name.includes(query);
      const matchesType = selectedType === "" || type === selectedType;

      div.style.display = matchesName && matchesType ? "block" : "none";
    });
  }

  searchInput?.addEventListener("input", filterProducts);
  typeFilter?.addEventListener("change", filterProducts);

  function getVisibleCheckboxes() {
    return Array.from(productCheckboxes).filter(div => div.style.display !== "none");
  }

  selectAllBtn?.addEventListener("click", function () {
    getVisibleCheckboxes().forEach(div => {
      const checkbox = div.querySelector("input[type='checkbox']");
      if (checkbox) checkbox.checked = true;
    });
  });

  deselectAllBtn?.addEventListener("click", function () {
    getVisibleCheckboxes().forEach(div => {
      const checkbox = div.querySelector("input[type='checkbox']");
      if (checkbox) checkbox.checked = false;
    });
  });

  // --- Обработка quantity promotions ---
  function toggleQuantityFields() {
    const isQuantity = discountTypeSelect.value === "quantity";

    quantityFields.style.display = isQuantity ? "block" : "none";

    if (singleDiscountField) {
      const wrapper = singleDiscountField.closest(".form-group") || singleDiscountField.parentElement;

      if (isQuantity) {
        singleDiscountField.value = 0;
        wrapper.style.display = "none"; // скрываем "Значение скидки"
      } else {
        wrapper.style.display = "block"; // показываем
      }
    }
  }

  discountTypeSelect?.addEventListener("change", toggleQuantityFields);
  toggleQuantityFields();

  let qpIndex = 1; // Начинаем с 1, так как 0 уже есть

  addBtn?.addEventListener("click", function () {
    const wrapper = document.createElement("div");
    wrapper.classList.add("quantity-promotion");
    wrapper.innerHTML = `
      <div style="margin-bottom: 8px;">
        <input type="number" name="promotion[quantity_promotions_attributes][${qpIndex}][min_quantity]" placeholder="Минимум шт.">
        <input type="number" step="0.01" name="promotion[quantity_promotions_attributes][${qpIndex}][discount_value]" placeholder="Скидка %">
        <button type="button" class="remove-qp" style="margin-left: 8px;">Удалить</button>
      </div>
    `;
    container.appendChild(wrapper);

    // Добавляем обработчик удаления
    wrapper.querySelector(".remove-qp").addEventListener("click", () => {
      wrapper.remove();
    });

    qpIndex++;
  });

  // Добавление кнопки "Удалить" к существующим блокам
  container.querySelectorAll(".quantity-promotion").forEach((block) => {
    const removeBtn = document.createElement("button");
    removeBtn.type = "button";
    removeBtn.className = "remove-qp";
    removeBtn.textContent = "Удалить";
    removeBtn.style.marginLeft = "8px";
    removeBtn.addEventListener("click", () => block.remove());
    block.appendChild(removeBtn);
  });
});