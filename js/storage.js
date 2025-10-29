// 로컬 스토리지 관리 클래스
class Storage {
    constructor() {
        this.HIGHSCORE_KEY = 'eyeCatchHighScore';
        this.SCORES_KEY = 'eyeCatchScores';
    }

    // 최고 점수 가져오기
    getHighScore() {
        const score = localStorage.getItem(this.HIGHSCORE_KEY);
        return score ? parseInt(score) : 0;
    }

    // 최고 점수 저장
    setHighScore(score) {
        localStorage.setItem(this.HIGHSCORE_KEY, score.toString());
    }

    // 점수 기록 저장
    saveScore(score, level, targets) {
        const scores = this.getAllScores();
        
        const newScore = {
            score: score,
            level: level,
            targets: targets,
            date: Date.now()
        };
        
        scores.push(newScore);
        
        // 점수 순으로 정렬
        scores.sort((a, b) => b.score - a.score);
        
        // 최대 50개까지만 저장
        const limitedScores = scores.slice(0, 50);
        
        localStorage.setItem(this.SCORES_KEY, JSON.stringify(limitedScores));
    }

    // 모든 점수 가져오기
    getAllScores() {
        const scores = localStorage.getItem(this.SCORES_KEY);
        return scores ? JSON.parse(scores) : [];
    }

    // 상위 N개 점수 가져오기
    getTopScores(n = 10) {
        const scores = this.getAllScores();
        return scores.slice(0, n);
    }

    // 데이터 초기화
    clearAll() {
        localStorage.removeItem(this.HIGHSCORE_KEY);
        localStorage.removeItem(this.SCORES_KEY);
    }
}

// 전역 인스턴스
const storage = new Storage();
