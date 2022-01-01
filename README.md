# 은행 창구 매니저 (in Yagom Academy)

저작권 문제로 App의 자세한 동작을 직접 설명을 공개할 수 없는 점 양해바랍니다

> **README 요약**
- 📝 Project Info.
- 🤖 App Operating
- ⚙️ 주요설계
- 🤔 당면한 문제 + 해결과정

---

## 📝 Project Info.
- `Project Copyright` : Yagom Academy
- `Contributor` : yohan, aCafela, hobak
- `Period` : 21.12.20 ~ 21.12.31 (2 weeks)
- `Tech. keyword`
    - Concurrency(GCD)
    - Configuring UI with Code
    - Struct vs Class

## 🤖 App Operating
![BankComplete](https://user-images.githubusercontent.com/39155090/147844092-d813aad0-4d46-443a-b78b-0bca47603bc6.gif)

## ⚙️ 주요설계
### 🔸 1. 동시성 구조
- 여러 고객들의 업무를 동시에 처리하기 위해 Concurrent Queue를 구성
- 메인 스레드는 UI 작업에 전념하도록, 세마포어 wait과 같은 Serial 작업을 시킬 별도의 Serial Queue 구성

![image](https://user-images.githubusercontent.com/39155090/147844642-cb3ea7f3-934b-4d23-9459-d6b3f3192520.png)

<br>

### 🔸 2. 코드로 UI 구성
스토리보드로 UI를 구성할 때와 유사하게 구현. 뷰컨에서 각 UI 요소들을 Implicitly Unwrapped Optional 프로퍼티 선언하고, `viewDidLoad()` 시점에 인스턴스 생성 및 설정
```swift
class MainViewController: UIViewController {
    
    private var addTenClientsButton: UIButton!
    private var resetButton: UIButton!
    private var serviceTimeLabel: UILabel!
    private var waitingQueueLabel: UILabel!
    ...
    
    override func viewDidLoad() {
        super.viewDidLoad()

        buildAllUIComponents()
	...
}

extension MainViewController {
    private func buildAllUIComponents() {
        buildButtons()
        buildServiceTimeLabel()
        buildQueueLabels()
        buildAllStackViews()
	...
}
```

#### ✅ 다른 방법: CustomView를 정의하여 그 인스턴스로 `view` 프로퍼티를 교체
UIView를 상속받는 `CustomView` 타입을 정의하고 UI 설정을 CustomView의 init()에서 하도록 설정. 이후 적절한 시점에 뷰컨의 `view` 프로퍼티를 CustomView의 인스턴스로 교체
- 장점 : View와 관련한 설정을 뷰컨으로부터 분리할 수 있다는 장점
- 단점 : 뷰컨의 `view` 프로퍼티는 `UIView` 타입으로 선언되었므로 CustomView 인스턴스로 교체하더라도 사용시점에 매번 타입 캐스팅이 필요

장.단점이 공존하므로 향후 소속 팀에서 결정된 방향으로 구현

<br>

### 🔸 3. Queue와 Bank를 class로 정의한 이유 (Class vs Struct)
결론적으로 Queue와 Bank 모두 class로 정의하였습니다

#### ✅ escaping closure에서 자신의 상태를 바꿔야 한다
비동기 작업은 escaping closure로 처리되므로, 만약 Bank를 struct로 정의하면 자신의 프로퍼티 변경을 비동기로 수행할 수 없게 됩니다. 이럴 경우, 구현 복잡도가 많이 올라가므로 득실을 따져야 했습니다

#### ✅ 참조타입 프로퍼티를 가진다
값타입을 사용함으로써 취하게 되는 장점으로 '현재 scope이 끝나면 인스턴스 해제가 보장된다는 점'과 '다른 상.변수로 할당하면 완전한 copy가 일어나는 점' 등을 꼽을 수 있습니다. 하지만, Queue와 Bank의 경우, struct로 정의하더라도 참조타입 stored 프로퍼티를 가지고 있어 실제로는 메모리 해제가 보장되지도, 완전한 copy가 일어나지도 않게 됩니다. 오히려 협업자가 struct로 정의된 것을 보고 이러한 장점을 온전히 가졌을 것이라고 잘못 판단할 우려가 있습니다. 따라서, 차라리 class로 정의하여 예측가능하도록 만드는 것이 더 중요하다 판단했습니다

<br>

## 🤔 당면한 문제 + 해결과정
### 🔸 1. GCD에서 비동기 작업을 취소할 방법 모색
#### 문제점
- 초기화 버튼의 눌리면 모든 작업이 중지되어야 하나, 비동기 Task들이 중지되지 못하고 UI를 업데이트하는 문제
- GCD에서는 Task를 직접적으로 취소할 기능이 없으므로 Operation을 사용해야 하나 프로젝트 기간이 하루밖에 남지 않아 GCD로 최선을 다해야 하는 상황

<img src="https://user-images.githubusercontent.com/39155090/147845012-8fb99a94-d6d1-4273-ae0e-8e0c67b51241.gif" width="30%">

#### ✅ 해결방법 - STEP1. Bank 인스턴스 해제
- 비동기 작업을 직접적으로 취소하는게 아닌, UI 업데이트 작업이 뷰에 적용되지 않도록 할 방법 모색
- 비동기 작업이 `self`(Bank 인스턴스)를 타고 UI 업데이트를 하므로 self가 메모리 해제되면 UI업데이트를 하지 못할 것으로 판단
- 초기화 버튼이 눌릴 시, Bank 인스턴스에 대한 강한 참조가 모두 해제되도록 처리
    - 뷰컨의 프로퍼티 `bank`에 새로운 인스턴스 할당
    - 타이머를 비롯한 비동기 작업 클로저에서 self에 대한 캡처를 weak로 변경

#### ✅ 해결방법 - STEP2. 나머지 GCD 프로퍼티는 강한 참조 유지
- 세마포어를 사용하므로 비동기 작업이 완료되어 스레드가 해제될 수 있도록 처리 
- self를 제외한 GCD 관련 프로퍼티(DispatchQueue, Group, Semaphore)는 강한 참조 유지
    
```swift
class Bank {
    private func processServiceAsync(queue: DispatchQueue, semaphore: DispatchSemaphore, client: Client) {
        //MARK: 초기화 버튼에 의해 self가 해제되므로, semaphore.signal()이 실행될 수 있도록 self.group에 대한 직접적인 참조를 확보
        let group = group
	queue.async(group: group) { [weak self] in
            semaphore.wait()
            DispatchQueue.main.sync {
                self?.delegate?.addToProcessingQueue(client: client)
                self?.delegate?.removeFromWaitingQueue(client: client)
            }
	    ...
}

class MainViewController: UIViewController {
    @objc private func resetAll() {
	bank = Bank(delegate: self)
	...
```
