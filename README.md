# nest-react-temp

## BEFORE

- Docker ([Docker Desktop](https://www.docker.com/products/docker-desktop/), [OrbStack](https://orbstack.dev/download), ...)

- [Kubectl](https://kubernetes.io/ru/docs/tasks/tools/install-kubectl/) - cli для k8s

- [Kind](https://kind.sigs.k8s.io/docs/user/quick-start) (я ставил в /usr/local/bin/kind) - локальный k8s кластер внутри докера

- [Сtlptl](https://github.com/tilt-dev/ctlptl?tab=readme-ov-file#how-do-i-install-it) - cli для управления локальным кластером

- [Tilt](https://docs.tilt.dev/install.html) - менеджер для локальной разработки внутри кластера

## START

### Локальный кластер
Заходим в корень репы и для начала создаем локальный кластер и регистри:
```shell
ctlptl apply -f cluster.yaml
```

После этого должно появится 2 контейнера в докере `ctlptl-registry` и `kind-control-plane`. У `kubectl` автоматически подставится контекст нового кластера.

> В регистри можно пушить и пулить свои имаджи btw. Тильт их хранит там.

Если все плохо и надо снести кластер:
```shell
ctlptl delete cluster kind-kind
```

### Запуск сервисов

В корне репы (как встанет жмать пробел для ui):
```shell
tilt up
```

### Сертификаты и хосты

Все сервисы которые торчат наружу из кластера должны быть с доменами. Для этого пишем в `/etc/hosts`:
```
127.0.0.1       backend.local
127.0.0.1       web.local
```

Дальше нужны сертификаты, чтобы браузер не ругался. Как в tilt ui все станет зеленое - забираем root ca:
```shell
kubectl get secret root-secret -n cert-manager -o jsonpath='{.data.ca\.crt}' | base64 -d > root-ca.crt
```

**Для Linux:**
```
sudo cp root-ca.crt /usr/local/share/ca-certificates/
sudo update-ca-certificates
```

**Для MacOS:**

2 тыка по root-ca.crt → откроется Keychain Access → вводим пароль → новый сертификат должен появится в списке → тыкаем 2 раза на него → Trust → в When using this certificate выстави «Always Trust» → close & save

## AFTER

https://backend.local:8443. Если открывается без ошибок и предупреждений - все ок.

## Нюансы

- Для локальной разработки на бэке надо `cp .env.example .env` и поменять хост к базе на `127.0.0.1`
- На бэке гкл временно отключен. Однако клиент уже умеет работать с гкл. Для тестирования он фетчит данные из внешнего урла и отображает на главной.
- Все проекты сгенерированы из предложенных фреймворками вариантов.
- Для мобильной версии - `pnpm start`. Тестировал только под ios + expo go на iphone. Если открывать через обычную вкладку поведение сильно отличается от нативного.
