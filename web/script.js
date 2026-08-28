window.addEventListener('message', (event) => {
    const data = event.data;

    if (data.action === 'openMenu') {
        openMenu(data.arenas, data.leaderboard);
    } else if (data.action === 'closeMenu') {
        closeMenu();
    } else if (data.action === 'showHUD') {
        document.getElementById('hud-container').classList.remove('hidden');
    } else if (data.action === 'hideHUD') {
        document.getElementById('hud-container').classList.add('hidden');
    } else if (data.action === 'updateHUD') {
        updateHUD(data.stats);
    }
});

document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        fetch(`https://${GetParentResourceName()}/closeMenu`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        });
    }
});

document.getElementById('close-btn').addEventListener('click', () => {
    fetch(`https://${GetParentResourceName()}/closeMenu`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
});

function openMenu(arenas, leaderboard) {
    const list = document.getElementById('arena-list');
    list.innerHTML = ''; // Clear previous

    arenas.forEach((arena) => {
        const isFull = arena.count >= arena.maxPlayers;

        const card = document.createElement('div');
        card.className = `arena-card ${isFull ? 'disabled' : ''}`;

        card.innerHTML = `
            <div class="arena-info">
                <h2>${arena.name}</h2>
                <p>${arena.description}</p>
            </div>
            <div class="arena-meta">
                <div class="player-count ${isFull ? 'full' : ''}">
                    <i class="fa-solid fa-users"></i> ${arena.count} / ${arena.maxPlayers}
                </div>
                <button class="join-btn">${isFull ? 'FULL' : 'JOIN'}</button>
            </div>
        `;

        if (!isFull) {
            card.addEventListener('click', () => {
                fetch(`https://${GetParentResourceName()}/joinArena`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ index: arena.index })
                });
            });
        }

        list.appendChild(card);
    });

    // Populate Leaderboard
    const lbList = document.getElementById('leaderboard-list');
    lbList.innerHTML = '';
    
    if (leaderboard && leaderboard.length > 0) {
        leaderboard.forEach(entry => {
            const row = document.createElement('div');
            row.className = 'leaderboard-row';
            if (entry.rank === 1) row.classList.add('rank-1');
            if (entry.rank === 2) row.classList.add('rank-2');
            if (entry.rank === 3) row.classList.add('rank-3');
            
            row.innerHTML = `
                <span class="l-rank">${entry.rank}</span>
                <span class="l-name">${entry.name}</span>
                <span class="l-stat">${entry.kills}</span>
                <span class="l-stat">${entry.deaths}</span>
                <span class="l-stat">${entry.kd.toFixed(2)}</span>
            `;
            lbList.appendChild(row);
        });
    } else {
        lbList.innerHTML = '<div class="no-data">No data available</div>';
    }

    document.getElementById('menu-container').classList.remove('hidden');
}

function closeMenu() {
    document.getElementById('menu-container').classList.add('hidden');
}

function updateHUD(stats) {
    document.getElementById('hud-kills').innerText = stats.kills;
    document.getElementById('hud-deaths').innerText = stats.deaths;
    document.getElementById('hud-kd').innerText = stats.kd.toFixed(2);
    document.getElementById('hud-streak').innerText = stats.streak;

    if (stats.leaveCommand) {
        document.getElementById('hud-leave-cmd').innerText = `Type /${stats.leaveCommand} to leave`;
    }
}
