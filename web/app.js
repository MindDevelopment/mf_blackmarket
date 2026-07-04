const state = { items: [], cart: {} }

const imagePath = 'nui://ox_inventory/web/images/'

function filterItems() {
    const filter = document.querySelector('.filter.active')?.dataset.filter || 'all'
    const query = document.getElementById('search').value.toLowerCase()
    document.querySelectorAll('.item-card').forEach(card => {
        const name = card.dataset.label.toLowerCase()
        const cat = card.dataset.category
        const matchesFilter = filter === 'all' || cat === filter
        const matchesSearch = name.includes(query)
        card.style.display = matchesFilter && matchesSearch ? 'flex' : 'none'
    })
}

function renderItems(items) {
    state.items = items
    const grid = document.getElementById('grid')
    grid.innerHTML = items.map(item => `
        <div class="item-card" data-category="${item.category}" data-label="${item.label}">
            <img src="${imagePath}${item.name}.png" alt="${item.label}">
            <div class="item-info">
                <span class="item-label">${item.label}</span>
                <span class="item-price">$${item.price.toLocaleString()}</span>
            </div>
            <button class="add-btn" onclick="addToCart('${item.name}', '${item.label}', ${item.price})">+ Add</button>
        </div>
    `).join('')
}

function renderCart() {
    const container = document.getElementById('cartItems')
    const entries = Object.entries(state.cart)
    if (entries.length === 0) {
        container.innerHTML = '<div class="empty-cart">Your cart is empty.</div>'
        document.getElementById('totalPrice').textContent = '$0'
        return
    }
    let total = 0
    container.innerHTML = entries.map(([name, entry]) => {
        total += entry.price * entry.amount
        return `
            <div class="cart-item">
                <div class="cart-item-info">
                    <span class="cart-item-label">${entry.label}</span>
                    <span class="cart-item-price">$${entry.price.toLocaleString()}</span>
                </div>
                <div class="cart-item-controls">
                    <button class="qty-btn" onclick="updateCart('${name}', -1)">-</button>
                    <span class="qty">${entry.amount}</span>
                    <button class="qty-btn" onclick="updateCart('${name}', 1)">+</button>
                    <button class="remove-btn" onclick="updateCart('${name}', -${entry.amount})">×</button>
                </div>
            </div>
        `
    }).join('')
    document.getElementById('totalPrice').textContent = `$${total.toLocaleString()}`
}

function addToCart(name, label, price) {
    if (state.cart[name]) {
        state.cart[name].amount++
    } else {
        state.cart[name] = { name, label, price, amount: 1 }
    }
    renderCart()
}

function updateCart(name, delta) {
    if (!state.cart[name]) return
    state.cart[name].amount += delta
    if (state.cart[name].amount <= 0) {
        delete state.cart[name]
    }
    renderCart()
}

function checkout(method) {
    const entries = Object.entries(state.cart)
    if (entries.length === 0) return
    const data = entries.map(([name, entry]) => ({ name, amount: entry.amount }))
    fetch(`https://${window.location.host}/buyItems`, {
        method: 'POST',
        body: JSON.stringify(data),
    })
}

window.addEventListener('message', function(event) {
    const data = event.data
    if (data.action === 'open') {
        document.getElementById('market').style.display = 'flex'
        renderItems(data.items)
    } else if (data.action === 'close') {
        document.getElementById('market').style.display = 'none'
        state.cart = {}
        renderCart()
    }
})

document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') {
        fetch(`https://${window.location.host}/close`, { method: 'POST' })
    }
})

document.querySelectorAll('.filter').forEach(btn => {
    btn.addEventListener('click', function() {
        document.querySelectorAll('.filter').forEach(b => b.classList.remove('active'))
        this.classList.add('active')
        filterItems()
    })
})
