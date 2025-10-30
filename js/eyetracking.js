// 아이트래킹 관리 클래스
class EyeTracking {
    constructor() {
        this.isInitialized = false;
        this.isCalibrated = false;
        this.gazeData = { x: 0, y: 0 };
        this.calibrationPoints = [];
        this.currentCalibrationIndex = 0;
        this.onGazeUpdate = null;
    }

    // 아이트래킹 초기화
    async initialize() {
        return new Promise((resolve, reject) => {
            try {
                // WebGazer 설정
                webgazer.params.showVideoPreview = true; // 비디오 프리뷰 활성화
                webgazer.params.showFaceOverlay = true; // 얼굴 오버레이 표시
                webgazer.params.showFaceFeedbackBox = true; // 피드백 박스 표시
                webgazer.params.showGazeDot = false;
                
                // WebGazer 시작
                webgazer.begin();
                
                // 비디오 크기 및 위치 조정
                webgazer.setVideoViewerSize(200, 150); // 작은 프리뷰 크기
                
                // 시선 추적 리스너 설정
                webgazer.setGazeListener((data, clock) => {
                    if (data) {
                        this.gazeData = {
                            x: data.x,
                            y: data.y
                        };
                        
                        // 시선 점 업데이트
                        this.updateGazeDot();
                        
                        // 콜백 호출
                        if (this.onGazeUpdate) {
                            this.onGazeUpdate(this.gazeData);
                        }
                    }
                });
                
                // 초기화 완료를 위해 3초 대기 (더 긴 초기화 시간)
                setTimeout(() => {
                    this.isInitialized = true;
                    console.log('아이트래킹 초기화 완료');
                    resolve();
                }, 3000);
                
            } catch (error) {
                console.error('아이트래킹 초기화 실패:', error);
                reject(error);
            }
        });
    }

    // 시선 점 업데이트
    updateGazeDot() {
        const gazeDot = document.getElementById('gaze-dot');
        if (gazeDot && this.gazeData.x && this.gazeData.y) {
            gazeDot.style.left = this.gazeData.x + 'px';
            gazeDot.style.top = this.gazeData.y + 'px';
        }
    }

    // 캘리브레이션 시작
    startCalibration(onComplete) {
        console.log('캘리브레이션 시작함수 호출');
        this.isCalibrated = false;
        this.currentCalibrationIndex = 0;
        this.onCalibrationComplete = onComplete;
        
        // 캘리브레이션 포인트 생성 (3x3 그리드)
        this.calibrationPoints = this.generateCalibrationPoints();
        console.log('캘리브레이션 포인트 생성:', this.calibrationPoints);
        this.renderCalibrationPoints();
        
        // 첫 번째 포인트 활성화
        this.activateCalibrationPoint(0);
    }

    // 캘리브레이션 포인트 생성
    generateCalibrationPoints() {
        const container = document.getElementById('calibration-container');
        const width = container.clientWidth;
        const height = container.clientHeight;
        
        const margin = 60;
        const positions = [
            { x: margin, y: margin }, // 왼쪽 상단
            { x: width / 2, y: margin }, // 중앙 상단
            { x: width - margin, y: margin }, // 오른쪽 상단
            { x: margin, y: height / 2 }, // 왼쪽 중앙
            { x: width / 2, y: height / 2 }, // 중앙
            { x: width - margin, y: height / 2 }, // 오른쪽 중앙
            { x: margin, y: height - margin }, // 왼쪽 하단
            { x: width / 2, y: height - margin }, // 중앙 하단
            { x: width - margin, y: height - margin } // 오른쪽 하단
        ];
        
        return positions;
    }

    // 캘리브레이션 포인트 렌더링
    renderCalibrationPoints() {
        const container = document.getElementById('calibration-container');
        if (!container) {
            console.error('캘리브레이션 컨테이너를 찾을 수 없습니다');
            return;
        }
        container.innerHTML = '';
        console.log('컨테이너 크기:', container.clientWidth, 'x', container.clientHeight);
        
        this.calibrationPoints.forEach((point, index) => {
            const pointElement = document.createElement('div');
            pointElement.className = 'calibration-point';
            pointElement.style.left = point.x + 'px';
            pointElement.style.top = point.y + 'px';
            pointElement.dataset.index = index;
            
            pointElement.addEventListener('click', () => {
                console.log('포인트 클릭:', index);
                this.onCalibrationPointClick(index);
            });
            
            // 터치 이벤트도 추가
            pointElement.addEventListener('touchstart', (e) => {
                e.preventDefault();
                console.log('포인트 터치:', index);
                this.onCalibrationPointClick(index);
            });
            
            container.appendChild(pointElement);
        });
        console.log('포인트 렌더링 완료, 총', this.calibrationPoints.length, '개');
    }

    // 캘리브레이션 포인트 활성화
    activateCalibrationPoint(index) {
        const points = document.querySelectorAll('.calibration-point');
        points.forEach((point, i) => {
            point.classList.remove('active');
            if (i < index) {
                point.classList.add('completed');
            }
        });
        
        if (index < points.length) {
            points[index].classList.add('active');
            
            // 진행률 업데이트
            document.getElementById('calibration-step').textContent = index + 1;
        }
    }

    // 캘리브레이션 포인트 클릭
    async onCalibrationPointClick(index) {
        console.log('포인트 클릭 처리:', index, '현재 인덱스:', this.currentCalibrationIndex);
        if (index !== this.currentCalibrationIndex) {
            console.log('순서가 맞지 않음');
            return;
        }
        
        const point = this.calibrationPoints[index];
        const container = document.getElementById('calibration-container');
        const rect = container.getBoundingClientRect();
        
        // 컨테이너 오프셋을 고려한 실제 화면 좌표
        const screenX = rect.left + point.x;
        const screenY = rect.top + point.y;
        
        console.log('캘리브레이션 좌표:', screenX, screenY);
        
        // WebGazer에 클릭 위치 등록
        await webgazer.recordScreenPosition(screenX, screenY);
        
        // 여러 번 클릭하여 정확도 향상
        for (let i = 0; i < 5; i++) {
            await new Promise(resolve => setTimeout(resolve, 100));
            await webgazer.recordScreenPosition(
                screenX + (Math.random() - 0.5) * 10,
                screenY + (Math.random() - 0.5) * 10
            );
        }
        
        this.currentCalibrationIndex++;
        console.log('다음 인덱스:', this.currentCalibrationIndex);
        
        if (this.currentCalibrationIndex < this.calibrationPoints.length) {
            // 다음 포인트로
            this.activateCalibrationPoint(this.currentCalibrationIndex);
        } else {
            // 캘리브레이션 완료
            console.log('모든 포인트 완료!');
            this.isCalibrated = true;
            if (this.onCalibrationComplete) {
                this.onCalibrationComplete();
            }
        }
    }

    // 시선이 특정 영역에 있는지 확인
    isGazeOnElement(element, threshold = 50) {
        if (!this.gazeData.x || !this.gazeData.y) return false;
        
        const rect = element.getBoundingClientRect();
        const centerX = rect.left + rect.width / 2;
        const centerY = rect.top + rect.height / 2;
        
        const distance = Math.sqrt(
            Math.pow(this.gazeData.x - centerX, 2) +
            Math.pow(this.gazeData.y - centerY, 2)
        );
        
        return distance < threshold;
    }

    // 시선 점 표시/숨김
    showGazeDot() {
        const gazeDot = document.getElementById('gaze-dot');
        if (gazeDot) {
            gazeDot.classList.add('active');
        }
    }

    hideGazeDot() {
        const gazeDot = document.getElementById('gaze-dot');
        if (gazeDot) {
            gazeDot.classList.remove('active');
        }
    }

    // 정리
    stop() {
        if (webgazer) {
            webgazer.pause();
        }
        this.hideGazeDot();
    }

    // 재시작
    resume() {
        if (webgazer && this.isInitialized) {
            webgazer.resume();
        }
    }

    // 현재 시선 위치 가져오기
    getCurrentGaze() {
        return this.gazeData;
    }
}

// 전역 인스턴스 생성
const eyeTracking = new EyeTracking();
