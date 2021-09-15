# BF2_ovnkube_deployment

## Usage

1. Clone repo https://github.com/pliurh/BF2_ovnkube_deployment
2. Replace kubeconfig.tenant file with the kubeconfig file of your tenant cluster.
3. Run ‘deploy.sh’
4. Label the DPU node.

   ```
   oc label node bf2-worker-advnetlab13 node-role.kubernetes.io/dpu=""
   ```

5. Annotate the ovnkub-node pod with the corresponding x86 host name and ip.
   Example:

   ```
   oc annotate pod ovnkube-node-gdr8g dpu.openshift.io/x86-node-ip=192.168.111.33
   oc annotate pod ovnkube-node-gdr8g dpu.openshift.io/x86-node-name=worker-advnetlab13
   ```
