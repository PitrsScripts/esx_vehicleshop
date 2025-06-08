// Výběr elementů
const vehicleShop = document.getElementById('vehicle-shop');
const searchInput = document.getElementById('searchInput');
const priceRange = document.getElementById('priceRange');
const minPriceInput = document.getElementById('minPriceInput');
const speedRange = document.getElementById('speedRange');
const maxSpeedInput = document.getElementById('maxSpeedInput');
const classFilter = document.getElementById('classFilter');
const maxPriceLabel = document.getElementById('maxPriceLabel');
const vehiclesGrid = vehicleShop.querySelector('.vehicles-grid');

// Globální proměnné
let categories = {};
let vehicles = {};
let currentVehicle = null;
let currentVehicleData = null;
let currentVehicleImage = null;
const colorMap = {
    'black': { r: 0, g: 0, b: 0 },
    'white': { r: 255, g: 255, b: 255 },
    'red': { r: 255, g: 0, b: 0 },
    'blue': { r: 0, g: 0, b: 255 },
    'green': { r: 0, g: 255, b: 0 },
    'yellow': { r: 255, g: 255, b: 0 },
    'orange': { r: 255, g: 165, b: 0 },
    'purple': { r: 128, g: 0, b: 128 },
    'pink': { r: 255, g: 192, b: 203 },
    'gray': { r: 128, g: 128, b: 128 }
};

// Test Drive Timer proměnné
let testDriveCountdown = null;
let testDriveTimeLeft = 0;



// Color Picker funkce
function openColorPicker(vehicleData) {
    console.log('Opening color picker for:', vehicleData);
    currentVehicleData = vehicleData;
    const colorPicker = document.getElementById('colorPicker');
    const mainShop = document.getElementById('vehicle-shop');
    const vehiclePreviewImage = document.getElementById('vehiclePreviewImage');
    const vehiclePrice = document.getElementById('vehiclePrice');
    
    // Nastavit obrázek vozidla
    vehiclePreviewImage.src = vehicleData.image || 'placeholder.png';
    
    // Nastavit cenu
    vehiclePrice.textContent = `${parseInt(vehicleData.price).toLocaleString()}`;
    
    mainShop.style.display = 'none';
    colorPicker.style.display = 'block';
    
    // Odstranit předchozí výběr
    document.querySelectorAll('.color-option').forEach(option => {
        option.classList.remove('selected');
    });
    
    // Nastavit první barvu jako výchozí
    const firstColor = document.querySelector('.color-option');
    if (firstColor) {
        firstColor.classList.add('selected');
        console.log('Selected color:', firstColor.dataset.color);
    }
    
    // Přidat event listenery na barvy
    document.querySelectorAll('.color-option').forEach(option => {
        option.addEventListener('click', function() {
            document.querySelectorAll('.color-option').forEach(opt => {
                opt.classList.remove('selected');
            });
            this.classList.add('selected');
            console.log('Selected color changed to:', this.dataset.color);
        });
    });
}
// Formátování času pro timer
function formatTime(seconds) {
    const minutes = Math.floor(seconds / 60);
    const remainingSeconds = seconds % 60;
    return `${minutes}:${remainingSeconds.toString().padStart(2, '0')}`;
}

// Funkce pro timer
function showTestDriveTimer(seconds) {
    const timerDiv = document.getElementById('testDriveTimer');
    const timerText = document.getElementById('testDriveTimerText');
    testDriveTimeLeft = seconds;
    
    clearInterval(testDriveCountdown);
    timerDiv.style.display = 'flex';
    
    setTimeout(() => {
        timerDiv.classList.add('visible');
    }, 100);

    timerText.textContent = `Test Drive: ${formatTime(testDriveTimeLeft)}`;
    
    testDriveCountdown = setInterval(() => {
        testDriveTimeLeft--;
        timerText.textContent = `Test Drive: ${formatTime(testDriveTimeLeft)}`;
        
        if (testDriveTimeLeft <= 10) {
            timerDiv.style.background = 'linear-gradient(90deg, #a02626 0%, #ad2323 100%)';
        }
        
        if (testDriveTimeLeft <= 0) {
            hideTestDriveTimer();
        }
    }, 1000);
}

function hideTestDriveTimer() {
    const timerDiv = document.getElementById('testDriveTimer');
    timerDiv.classList.remove('visible');
    setTimeout(() => {
        timerDiv.style.display = 'none';
        timerDiv.style.background = 'linear-gradient(90deg, #2642a0 0%, #2356ad 100%)';
    }, 300);
    clearInterval(testDriveCountdown);
}

// Collapsible menu pro filtr vozidel
document.addEventListener('DOMContentLoaded', function () {
    document.querySelectorAll('.collapsible-toggle').forEach(btn => {
        btn.addEventListener('click', function () {
            const filter = btn.closest('.collapsible-filter');
            filter.classList.toggle('open');
        });
    });

    minPriceInput.value = priceRange.value;
    maxSpeedInput.value = speedRange.value;
    updateSliderUI();
    updateSpeedSliderUI();
    
    // Přidat event listenery na barvy
    document.querySelectorAll('.color-option').forEach(option => {
        option.addEventListener('click', function() {
            document.querySelectorAll('.color-option').forEach(opt => {
                opt.classList.remove('selected');
            });
            this.classList.add('selected');
            console.log('Selected color:', this.dataset.color);
        });
    });
});

// Funkce pro aktualizaci UI
function updateSliderUI() {
    const max = parseInt(priceRange.max, 10);
    const val = parseInt(priceRange.value, 10);
    if (isNaN(max) || isNaN(val) || max === 0) return;
    const percentage = (val / max) * 100;
    priceRange.style.background = `linear-gradient(to right, #385fad 0%, #385fad ${percentage}%, #444 ${percentage}%, #444 100%)`;
    if (maxPriceLabel) {
        maxPriceLabel.textContent = `$${val.toLocaleString()}`;
    }
}

function updateSpeedSliderUI() {
    const max = parseInt(speedRange.max, 10);
    const val = parseInt(speedRange.value, 10);
    if (isNaN(max) || isNaN(val) || max === 0) return;
    const percentage = (val / max) * 100;
    speedRange.style.background = `linear-gradient(to right, #385fad 0%, #385fad ${percentage}%, #444 ${percentage}%, #444 100%)`;
}

// Event Listeners pro Color Picker
document.getElementById('confirmColorBtn').addEventListener('click', () => {
    const selectedColor = document.querySelector('.color-option.selected');
    if (selectedColor && currentVehicleData) {
        const colorName = selectedColor.dataset.color;
        const color = colorMap[colorName];
        
        console.log(`Confirming purchase of ${currentVehicleData.model} for ${currentVehicleData.price} in ${colorName} color`);
        
        // Zobrazit zprávu o zpracování
        const colorPicker = document.getElementById('colorPicker');
        const vehiclePrice = document.getElementById('vehiclePrice');
        vehiclePrice.textContent = 'Processing purchase...';
        
        fetch(`https://${GetParentResourceName()}/confirmPurchase`, {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({
                model: currentVehicleData.model,
                price: currentVehicleData.price,
                color: color
            })
        }).then(response => {
            console.log('Purchase request sent');
            document.getElementById('colorPicker').style.display = 'none';
            document.getElementById('vehicle-shop').style.display = 'none';
        }).catch(error => {
            console.error('Error sending purchase request:', error);
            vehiclePrice.textContent = 'Error processing purchase';
            setTimeout(() => {
                vehiclePrice.textContent = `${parseInt(currentVehicleData.price).toLocaleString()}`;
            }, 2000);
        });
    } else {
        console.error('Missing color selection or vehicle data');
    }
});

document.getElementById('backFromColorBtn').addEventListener('click', () => {
    document.getElementById('colorPicker').style.display = 'none';
    document.getElementById('vehicle-shop').style.display = 'block';
});

// Synchronizace inputu a slideru pro cenu
minPriceInput.addEventListener('input', () => {
    let val = parseInt(minPriceInput.value, 10);
    if (isNaN(val) || minPriceInput.value === '') val = 0;
    if (val > parseInt(priceRange.max, 10)) {
        val = parseInt(priceRange.max, 10);
        minPriceInput.value = val;
    }
    priceRange.value = val;
    updateSliderUI();
    populateVehiclesGrid();
});

priceRange.addEventListener('input', () => {
    minPriceInput.value = priceRange.value;
    updateSliderUI();
    populateVehiclesGrid();
});

// Synchronizace inputu a slideru pro rychlost
maxSpeedInput.addEventListener('input', () => {
    let val = parseInt(maxSpeedInput.value, 10);
    if (isNaN(val) || maxSpeedInput.value === '') val = 0;
    if (val > parseInt(speedRange.max, 10)) {
        val = parseInt(speedRange.max, 10);
        maxSpeedInput.value = val;
    }
    speedRange.value = val;
    const speedValue = document.getElementById('speedValue');
    if (speedValue) {
        speedValue.textContent = `${val} mph`;
    }
    updateSpeedSliderUI();
    populateVehiclesGrid();
});

speedRange.addEventListener('input', () => {
    maxSpeedInput.value = speedRange.value;
    const speedValue = document.getElementById('speedValue');
    if (speedValue) {
        speedValue.textContent = `${speedRange.value} mph`;
    }
    updateSpeedSliderUI();
    populateVehiclesGrid();
});

// Pomocné funkce
function getSelectedCategories() {
    return Array.from(classFilter.querySelectorAll('input[type="checkbox"]:checked'))
        .map(box => box.value.trim().toLowerCase());
}

// Zpracování zpráv
window.addEventListener('message', (event) => {
    const data = event.data;
    if (data.action === 'open') {
        document.getElementById('colorPicker').style.display = 'none';
        vehicleShop.style.display = 'block';
        categories = data.categories;
        vehicles = data.vehicles;
        updateSliderUI();
        updateSpeedSliderUI();
        populateVehiclesGrid();
    } else if (data.action === 'close') {
        vehicleShop.style.display = 'none';
        document.getElementById('colorPicker').style.display = 'none';
        clearSelection();
    } else if (data.action === 'startTestDriveTimer') {
        showTestDriveTimer(data.time || 60);
    } else if (data.action === 'endTestDriveTimer') {
        hideTestDriveTimer();
    } else if (data.action === 'openColorPicker') {
        openColorPicker(data.vehicle);
    } else if (data.action === 'closeColorPicker') {
        document.getElementById('colorPicker').style.display = 'none';
        vehicleShop.style.display = 'block';
    }
});

// Hlavní funkce pro zobrazení vozidel
function populateVehiclesGrid() {
    vehiclesGrid.innerHTML = '';

    let filteredVehicles = Object.values(vehicles).flat();

    // Filtrování podle kategorií
    const selectedCategories = getSelectedCategories();
    if (selectedCategories.length > 0) {
        filteredVehicles = filteredVehicles.filter(vehicle => {
            let cat = vehicle.category;
            if (!cat) {
                for (const catKey in vehicles) {
                    if (vehicles[catKey].some(v => v.model === vehicle.model)) {
                        cat = catKey;
                        break;
                    }
                }
            }
            return selectedCategories.includes(String(cat).trim().toLowerCase());
        });
    }

    // Filtrování podle ceny
    const maxPrice = parseInt(priceRange.value, 10);
    filteredVehicles = filteredVehicles.filter(vehicle => {
        const price = parseInt(vehicle.price, 10);
        return price <= maxPrice;
    });

    // Filtrování podle rychlosti
    const maxSpeed = parseInt(speedRange.value, 10);
    filteredVehicles = filteredVehicles.filter(v => {
        if (!v.speed) return false;
        const speedNum = parseInt(String(v.speed).replace(' mph', ''), 10);
        return speedNum <= maxSpeed;
    });

    // Filtrování podle vyhledávání
    if (searchInput.value.trim()) {
        const searchTerm = searchInput.value.trim().toLowerCase();
        filteredVehicles = filteredVehicles.filter(v => 
            v.label.toLowerCase().includes(searchTerm)
        );
    }

    // Vykreslení vozidel
    filteredVehicles.forEach(vehicle => {
        const card = document.createElement('div');
        card.classList.add('vehicle-card');

        let vehicleCategory = '';
        if (vehicle.category) {
            vehicleCategory = vehicle.category;
        } else {
            for (const catKey in vehicles) {
                if (vehicles[catKey].some(v => v.model === vehicle.model)) {
                    vehicleCategory = catKey;
                    break;
                }
            }
        }

        const imageSrc = vehicle.image && vehicle.image.trim() !== '' ? vehicle.image : 'placeholder.png';
        let speed = vehicle.speed ? vehicle.speed : 'N/A';
        let seats = vehicle.seats ? vehicle.seats : 'N/A';

        if (typeof speed === 'string') {
            speed = speed.replace(' mph', '');
        }
        if (typeof seats === 'string') {
            seats = seats.replace('x', '');
        }

        card.innerHTML = `
            <div style="position: relative;">
                <img src="${imageSrc}" alt="${vehicle.label}" style="width: 100%; border-radius: 8px 8px 0 0; height: 120px; object-fit: cover;" />
                <div style="position: absolute; top: 8px; left: 8px; background: rgba(0,0,0,0.7); color: white; padding: 2px 6px; border-radius: 4px; font-size: 12px;">$${parseInt(vehicle.price).toLocaleString()}</div>
            </div>
            <div style="padding: 8px;">
                <h3 style="margin: 0 0 4px 0; color: white;">
                    ${vehicle.label}
                    <span style="float: right; color: #aaa; font-weight: normal;">${vehicleCategory}</span>
                </h3>
                <div class="icon-row">
                    <div class="icon-speed">
                        <span class="icon-speed-bg">
                            <span class="icon-img"></span>
                        </span>
                        <span class="icon-value">${speed} mph</span>
                    </div>
                    <div class="icon-seats">
                        <span class="icon-img"></span>
                        <span class="icon-value">${seats}x</span>
                    </div>
                </div>
                <div class="vehicle-actions">
                    <button class="btn buy">
                        <span class="btn-icon">
                            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 16 16" fill="#385fad"><g fill="#385fad"><path d="M8 10a2 2 0 1 0 0-4a2 2 0 0 0 0 4z"/><path d="M0 4a1 1 0 0 1 1-1h14a1 1 0 0 1 1 1v8a1 1 0 0 1-1 1H1a1 1 0 0 1-1-1V4zm3 0a2 2 0 0 1-2 2v4a2 2 0 0 1 2 2h10a2 2 0 0 1 2-2V6a2 2 0 0 1-2-2H3z"/></g></svg>
                        </span>
                        Buy
                    </button>
                    <button class="btn test-drive">
                                            <span class="btn-icon">
                            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 384 384" fill="#385fad"><path fill="#385fad" d="m340 64l44 128v171q0 8-6.5 14.5T363 384h-22q-8 0-14.5-6.5T320 363v-22H64v22q0 8-6.5 14.5T43 384H21q-8 0-14.5-6.5T0 363V192L44 64q8-21 31-21h234q23 0 31 21zM74.5 277q13.5 0 23-9t9.5-22.5t-9.5-23t-23-9.5t-22.5 9.5t-9 23t9 22.5t22.5 9zm235 0q13.5 0 22.5-9t9-22.5t-9-23t-22.5-9.5t-23 9.5t-9.5 23t9.5 22.5t23 9zM43 171h298l-32-96H75z"/></svg>
                        </span>
                        Test Drive
                    </button>
                </div>
            </div>
        `;

        // Event listener pro Buy tlačítko
        card.querySelector('.btn.buy').addEventListener('click', () => {
            console.log(`Buy button clicked for ${vehicle.model} with price ${vehicle.price}`);
            openColorPicker({
                model: vehicle.model,
                label: vehicle.label,
                price: vehicle.price,
                image: vehicle.image || 'placeholder.png'
            });
        });

        // Event listener pro Test Drive tlačítko
        card.querySelector('.btn.test-drive').addEventListener('click', () => {
            fetch(`https://${GetParentResourceName()}/startTestDrive`, {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({model: vehicle.model})
            });
            vehicleShop.style.display = 'none';
        });

        vehiclesGrid.appendChild(card);
    });
}

// Funkce pro vyčištění výběru
function clearSelection() {
    currentVehicle = null;
    currentVehicleData = null;
    classFilter.querySelectorAll('input[type="checkbox"]').forEach(cb => cb.checked = false);
    priceRange.value = priceRange.max;
    minPriceInput.value = priceRange.max;
    speedRange.value = speedRange.max;
    maxSpeedInput.value = speedRange.max;
    searchInput.value = '';
    updateSliderUI();
    updateSpeedSliderUI();
    populateVehiclesGrid();
}

// Event listeners pro filtry
classFilter.addEventListener('change', populateVehiclesGrid);
searchInput.addEventListener('input', populateVehiclesGrid);

// Event listener pro tlačítko odchodu
const leaveBtn = document.getElementById('leaveBtn');
leaveBtn.addEventListener('click', () => {
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({})
    });
});

// Event listener pro klávesu ESC
document.addEventListener('keyup', (event) => {
    if (event.key === 'Escape') {
        if (document.getElementById('colorPicker').style.display === 'block') {
            document.getElementById('colorPicker').style.display = 'none';
            document.getElementById('vehicle-shop').style.display = 'block';
        } else {
            fetch(`https://${GetParentResourceName()}/close`, {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({})
            });
        }
    }
});