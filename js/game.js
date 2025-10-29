// 게임 관리 클래스
class Game {
    constructor() {
        this.state = 'menu'; // menu, calibration, playing, gameover
        this.score = 0;
        this.level = 1;
        this.timeLeft = 60;
        this.targets = [];
        this.targetsCaught = 0;
        this.targetsSpawned = 0;
        this.gameInterval = null;
        this.spawnInterval = null;
        this.highScore = 0;
    }

    // 게임 초기화
    init() {
        this.loadHighScore();
        this.updateHighScoreDisplay();
    }

    // 메인 화면 표시
    showMainScreen() {
        this.hideAllScreens();
        document.getElementById('main-screen').classList.add('active');
        this.state = 'menu';
        eyeTracking.stop();
    }

    // 게임 방법 표시
    showInstructions() {
        this.hideAllScreens();
        document.getElementById('instructions-screen').classList.add('active');
    }

    // 순위표 표시
    showLeaderboard() {
        this.hideAllScreens();
        document.getElementById('leaderboard-screen').classList.add('active');
        this.renderLeaderboard();
    }

    // 캘리브레이션 화면 표시
    showCalibration() {
        this.hideAllScreens();
        document.getElementById('calibration-screen').classList.add('active');
        this.state = 'calibration';
        
        // 아이트래킹 초기화 및 캘리브레이션 시작
        if (!eyeTracking.isInitialized) {
            this.showLoading('아이트래킹 초기화 중...');
            eyeTracking.initialize().then(() => {
                this.hideLoading();
                eyeTracking.startCalibration(() => {
                    // 캘리브레이션 완료 후 게임 시작
                    setTimeout(() => this.startGame(), 500);
                });
            }).catch(error => {
                this.hideLoading();
                alert('카메라 권한이 필요합니다. 브라우저 설정에서 카메라를 허용해주세요.');
                this.showMainScreen();
            });
        } else {
            eyeTracking.startCalibration(() => {
                setTimeout(() => this.startGame(), 500);
            });
        }
    }

    // 게임 시작
    startGame() {
        this.hideAllScreens();
        document.getElementById('game-screen').classList.add('active');
        this.state = 'playing';
        
        // 게임 상태 초기화
        this.score = 0;
        this.level = 1;
        this.timeLeft = 60;
        this.targets = [];
        this.targetsCaught = 0;
        this.targetsSpawned = 0;
        
        // UI 업데이트
        this.updateGameUI();
        
        // 시선 점 표시
        eyeTracking.showGazeDot();
        eyeTracking.resume();
        
        // 타겟 스폰 시작
        this.spawnTarget();
        this.spawnInterval = setInterval(() => {
            this.spawnTarget();
        }, this.getSpawnInterval());
        
        // 게임 타이머 시작
        this.gameInterval = setInterval(() => {
            this.timeLeft--;
            this.updateGameUI();
            
            if (this.timeLeft <= 0) {
                this.endGame();
            }
            
            // 레벨업 체크 (10초마다)
            if (this.timeLeft % 10 === 0 && this.timeLeft !== 60) {
                this.levelUp();
            }
        }, 1000);
        
        // 시선 감지 체크
        this.checkGazeInterval = setInterval(() => {
            this.checkGazeOnTargets();
        }, 100);
    }

    // 타겟 스폰
    spawnTarget() {
        if (this.state !== 'playing') return;
        
        const canvas = document.getElementById('game-canvas');
        const target = document.createElement('div');
        
        // 타겟 타입 결정 (10% 확률로 보너스)
        const isBonus = Math.random() < 0.1;
        target.className = isBonus ? 'target bonus' : 'target normal';
        
        // 크기 (레벨이 올라갈수록 작아짐)
        const size = Math.max(60 - (this.level * 5), 30);
        target.style.width = size + 'px';
        target.style.height = size + 'px';
        
        // 랜덤 위치
        const maxX = canvas.clientWidth - size;
        const maxY = canvas.clientHeight - size;
        const x = Math.random() * maxX;
        const y = Math.random() * maxY;
        
        target.style.left = x + 'px';
        target.style.top = y + 'px';
        
        // 진행 표시 요소
        const progress = document.createElement('div');
        progress.className = 'target-progress';
        target.appendChild(progress);
        
        // 타겟 데이터
        const targetData = {
            element: target,
            progress: progress,
            isBonus: isBonus,
            gazeTime: 0,
            requiredTime: 2000, // 2초
            lastCheck: Date.now()
        };
        
        this.targets.push(targetData);
        canvas.appendChild(target);
        this.targetsSpawned++;
        
        // 일정 시간 후 타겟 제거 (5초 + 레벨에 따른 감소)
        setTimeout(() => {
            this.removeTarget(targetData);
        }, Math.max(5000 - (this.level * 200), 3000));
    }

    // 시선이 타겟에 있는지 확인
    checkGazeOnTargets() {
        if (this.state !== 'playing') return;
        
        const now = Date.now();
        
        this.targets.forEach(targetData => {
            if (!targetData.element.parentNode) return;
            
            const isGazing = eyeTracking.isGazeOnElement(
                targetData.element,
                targetData.element.clientWidth / 2
            );
            
            if (isGazing) {
                // 시선이 타겟에 있음
                const elapsed = now - targetData.lastCheck;
                targetData.gazeTime += elapsed;
                
                // 진행률 업데이트
                const progress = (targetData.gazeTime / targetData.requiredTime) * 360;
                targetData.progress.style.transform = `rotate(${progress}deg)`;
                
                // 완료 체크
                if (targetData.gazeTime >= targetData.requiredTime) {
                    this.catchTarget(targetData);
                }
            } else {
                // 시선이 타겟에서 벗어남 - 진행률 감소
                targetData.gazeTime = Math.max(0, targetData.gazeTime - 100);
                const progress = (targetData.gazeTime / targetData.requiredTime) * 360;
                targetData.progress.style.transform = `rotate(${progress}deg)`;
            }
            
            targetData.lastCheck = now;
        });
    }

    // 타겟 캐치
    catchTarget(targetData) {
        if (!targetData.element.parentNode) return;
        
        // 점수 추가
        const points = targetData.isBonus ? 20 : 10;
        this.score += points;
        this.targetsCaught++;
        
        // 시각적 피드백
        targetData.element.style.transform = 'scale(1.5)';
        targetData.element.style.opacity = '0';
        
        // 타겟 제거
        setTimeout(() => {
            this.removeTarget(targetData);
        }, 200);
        
        // UI 업데이트
        this.updateGameUI();
    }

    // 타겟 제거
    removeTarget(targetData) {
        const index = this.targets.indexOf(targetData);
        if (index > -1) {
            this.targets.splice(index, 1);
        }
        
        if (targetData.element.parentNode) {
            targetData.element.parentNode.removeChild(targetData.element);
        }
    }

    // 레벨업
    levelUp() {
        this.level++;
        this.updateGameUI();
        
        // 스폰 간격 조정
        if (this.spawnInterval) {
            clearInterval(this.spawnInterval);
            this.spawnInterval = setInterval(() => {
                this.spawnTarget();
            }, this.getSpawnInterval());
        }
    }

    // 스폰 간격 계산
    getSpawnInterval() {
        return Math.max(2000 - (this.level * 100), 1000);
    }

    // 게임 종료
    endGame() {
        this.state = 'gameover';
        
        // 인터벌 정리
        if (this.gameInterval) {
            clearInterval(this.gameInterval);
        }
        if (this.spawnInterval) {
            clearInterval(this.spawnInterval);
        }
        if (this.checkGazeInterval) {
            clearInterval(this.checkGazeInterval);
        }
        
        // 타겟 정리
        this.targets.forEach(targetData => {
            this.removeTarget(targetData);
        });
        
        // 최고 점수 업데이트
        if (this.score > this.highScore) {
            this.highScore = this.score;
            this.saveHighScore();
            storage.saveScore(this.score, this.level, this.targetsCaught);
        }
        
        // 게임 오버 화면 표시
        this.showGameOver();
        
        // 아이트래킹 정지
        eyeTracking.stop();
    }

    // 게임 오버 화면 표시
    showGameOver() {
        this.hideAllScreens();
        document.getElementById('gameover-screen').classList.add('active');
        
        // 최종 점수 표시
        document.getElementById('final-score').textContent = this.score;
        document.getElementById('final-level').textContent = this.level;
        document.getElementById('targets-caught').textContent = this.targetsCaught;
        
        const accuracy = this.targetsSpawned > 0 
            ? Math.round((this.targetsCaught / this.targetsSpawned) * 100)
            : 0;
        document.getElementById('accuracy').textContent = accuracy + '%';
        
        // 메시지 표시
        const message = this.getScoreMessage();
        document.getElementById('score-message').textContent = message;
    }

    // 점수에 따른 메시지
    getScoreMessage() {
        if (this.score >= 500) return '🏆 전설이다! 완벽해요!';
        if (this.score >= 300) return '⭐ 대단해요! 아주 잘하셨어요!';
        if (this.score >= 200) return '👍 잘했어요! 계속 연습하세요!';
        if (this.score >= 100) return '😊 좋아요! 더 잘할 수 있어요!';
        return '💪 다시 도전해보세요!';
    }

    // 게임 재시작
    restartGame() {
        this.showCalibration();
    }

    // 게임 UI 업데이트
    updateGameUI() {
        document.getElementById('current-score').textContent = this.score;
        document.getElementById('current-level').textContent = this.level;
        document.getElementById('time-left').textContent = this.timeLeft;
    }

    // 최고 점수 표시 업데이트
    updateHighScoreDisplay() {
        document.getElementById('high-score').textContent = this.highScore;
    }

    // 순위표 렌더링
    renderLeaderboard() {
        const list = document.getElementById('leaderboard-list');
        const scores = storage.getTopScores(10);
        
        if (scores.length === 0) {
            list.innerHTML = '<p style="text-align: center; color: var(--text-secondary);">아직 기록이 없습니다.</p>';
            return;
        }
        
        list.innerHTML = scores.map((score, index) => {
            let rankClass = '';
            if (index === 0) rankClass = 'gold';
            else if (index === 1) rankClass = 'silver';
            else if (index === 2) rankClass = 'bronze';
            
            return `
                <div class="leaderboard-item">
                    <div class="leaderboard-rank ${rankClass}">#${index + 1}</div>
                    <div class="leaderboard-info">
                        <div class="leaderboard-date">${this.formatDate(score.date)}</div>
                        <div>레벨 ${score.level} · 타겟 ${score.targets}개</div>
                    </div>
                    <div class="leaderboard-score">${score.score}</div>
                </div>
            `;
        }).join('');
    }

    // 날짜 포맷
    formatDate(timestamp) {
        const date = new Date(timestamp);
        const month = date.getMonth() + 1;
        const day = date.getDate();
        const hours = date.getHours();
        const minutes = date.getMinutes().toString().padStart(2, '0');
        return `${month}월 ${day}일 ${hours}:${minutes}`;
    }

    // 모든 화면 숨김
    hideAllScreens() {
        document.querySelectorAll('.screen').forEach(screen => {
            screen.classList.remove('active');
        });
    }

    // 로딩 표시
    showLoading(text = '로딩 중...') {
        const overlay = document.getElementById('loading-overlay');
        const textElement = overlay.querySelector('.loading-text');
        textElement.textContent = text;
        overlay.classList.add('active');
    }

    // 로딩 숨김
    hideLoading() {
        document.getElementById('loading-overlay').classList.remove('active');
    }

    // 최고 점수 불러오기
    loadHighScore() {
        this.highScore = storage.getHighScore();
    }

    // 최고 점수 저장
    saveHighScore() {
        storage.setHighScore(this.highScore);
    }
}

// 전역 게임 인스턴스
const game = new Game();
