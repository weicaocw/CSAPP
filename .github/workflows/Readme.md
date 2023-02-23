
### 1. When PR created

pr-check.yml:

```
===========> ************************
             *  golang-lint         *
             *  unit test           *
             *  build (make build)  *
             ************************
```

### 2. When comment (trigger.yml)

#### /integration

trigger.yml -> pr-integration.yml:

```
                        -- pr branch + nightly_5x.rpm --

      ******************************        **********************************
====> * integration-runner.yml:    * =====> * integration-runner.yml         *
      *  aws:                      *        *   feishu notification(if fail) *
      *    e2e (terraform-e2e.yml) *        *   notify pipeline screen       *
      ******************************        **********************************
```


### 3. After PR Merged into master & any push on master

master-health-check.yml


```
                                               -- master --
===========> ****************************** ==========> **********************************
             *  golang-lint               *             *  notify pipeline screen        *
             *  unit test                 *             *  feishu notification(if fail)  *
             *  build (make build)        *             **********************************
             ******************************             
             ******************************
             * integration-runner.yml:    *
             *  aws:                      *
             *    e2e (terraform-e2e.yml) *
             ******************************
```

