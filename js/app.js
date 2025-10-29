// 앱 초기화
document.addEventListener('DOMContentLoaded', () => {
    // 게임 초기화
    game.init();
    
    // PWA 설치 프롬프트 처리
    let deferredPrompt;
    
    window.addEventListener('beforeinstallprompt', (e) => {
        e.preventDefault();
        deferredPrompt = e;
        
        // 설치 버튼 표시 (선택사항)
        console.log('PWA 설치 가능');
    });
    
    // PWA 설치 함수 (나중에 버튼에 연결 가능)
    window.installPWA = () => {
        if (deferredPrompt) {
            deferredPrompt.prompt();
            deferredPrompt.userChoice.then((choiceResult) => {
                if (choiceResult.outcome === 'accepted') {
                    console.log('PWA 설치됨');
                }
                deferredPrompt = null;
            });
        }
    };
    
    // 화면 방향 고정 시도 (모바일)
    if (screen.orientation && screen.orientation.lock) {
        screen.orientation.lock('portrait').catch(err => {
            console.log('화면 방향 고정 실패:', err);
        });
    }
    
    // 백그라운드 전환 시 아이트래킹 일시정지
    document.addEventListener('visibilitychange', () => {
        if (document.hidden) {
            if (game.state === 'playing') {
                eyeTracking.stop();
            }
        } else {
            if (game.state === 'playing') {
                eyeTracking.resume();
            }
        }
    });
    
    // 터치 이벤트 최적화
    document.addEventListener('touchstart', () => {}, { passive: true });
    
    console.log('Eye Catch 게임 준비 완료! 👁️');
});

// 서비스 워커 등록 (PWA)
if ('serviceWorker' in navigator) {
    window.addEventListener('load', () => {
        navigator.serviceWorker.register('/sw.js')
            .then(registration => {
                console.log('Service Worker 등록 성공:', registration.scope);
            })
            .catch(error => {
                console.log('Service Worker 등록 실패:', error);
            });
    });
}
