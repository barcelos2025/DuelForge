# Plano de QA e Ferramentas de Debug de Batalha

**Contexto:** DuelForge (Flutter + Flame)  
**Objetivo:** Garantir estabilidade, determinismo e jogabilidade "bug-free".

---

## 1. Estratégia de Testes Automatizados

### Testes Unitários (Lógica Pura)
Focados no `BattleEngine` e `BattleState`, sem dependência do Flame.

1.  **Recursos:**
    *   Verificar regeneração de Elixir (ex: +1 a cada 20 ticks).
    *   Verificar consumo ao jogar carta.
    *   Verificar bloqueio de carta sem Elixir suficiente.
2.  **Spawn:**
    *   Validar spawn na zona aliada (Sucesso).
    *   Validar spawn na zona inimiga (Falha).
    *   Validar colisão de construção sobre construção (Falha).
3.  **Targeting:**
    *   Unidade A ignora Unidade B (fora de alcance).
    *   Unidade A foca Unidade B (dentro de alcance).
    *   Unidade Ground ignora Unidade Air (se TargetMask for GroundOnly).
    *   Torre troca de alvo quando o atual morre.
4.  **Status Effects:**
    *   Veneno aplica dano X vezes e expira.
    *   Stun impede ataque e movimento.
    *   Slow reduz velocidade corretamente e não stacka (maior prevalece).
5.  **Win Conditions:**
    *   Destruição da Torre do Rei encerra partida imediatamente.
    *   Fim do tempo com HP igual inicia Overtime.
    *   Fim do Overtime com HP igual resulta em Empate.

### Cenários de Teste (Integration/Simulation)
Lista de 20+ cenários essenciais para rodar em loop (Bot vs Bot ou Scripted):

1.  **1v1 Básico:** Guerreiro vs Guerreiro no meio da ponte. Quem ganha? (Deve ser consistente).
2.  **Horda vs AOE:** Exército de esqueletos vs 1 Mago/Valquíria. (Teste de eficiência de AOE).
3.  **Kiting:** Unidade rápida (Arqueira) fugindo de unidade lenta (Gigante).
4.  **Tower Aggro:** Unidade entra no range da torre, toma hit, sai do range, torre para.
5.  **Retargeting:** Unidade A matando B, deve virar imediatamente para C.
6.  **Projectile Chase:** Projétil teleguiado seguindo alvo que usou Dash/Teleporte.
7.  **Projectile Miss:** Projétil skillshot errando alvo móvel.
8.  **Death Cleanup:** Garantir que unidade morta não bloqueia caminho nem causa dano.
9.  **Stun Interrupt:** Stunar unidade no meio da animação de ataque (deve cancelar dano).
10. **Push Physics:** Duas unidades colidindo de frente (não devem atravessar/vibrar).
11. **Bridge Choke:** 10 unidades tentando passar na ponte ao mesmo tempo (pathfinding stress).
12. **Building Block:** Colocar construção no caminho de um Gigante (ele deve desviar ou atacar).
13. **Spell Edge:** Unidade na borda exata da Bola de Fogo (deve tomar dano).
14. **Overtime Trigger:** Jogo empatado aos 3:00 exatos.
15. **Sudden Death:** Primeira torre caindo no Overtime encerra jogo no tick exato.
16. **Double KO:** Torres se destruindo no mesmo tick (Empate ou lógica de HP restante).
17. **Effect Expiry:** Veneno acabando exatamente antes de matar (unidade fica com 1 HP).
18. **Attack Speed Buff:** Rage aplicado, verificar aumento de DPS.
19. **Range Buff:** (Se houver) Unidade atirando de mais longe.
20. **Disconnect Sim:** Simular falta de input por 10s, depois voltar (Catch-up).

---

## 2. Checklist de Bugs Clássicos (e como detectar)

| Bug | Sintoma | Detecção Automática (Asserts) |
| :--- | :--- | :--- |
| **Tunneling** | Unidade atravessa muro/rio em alta velocidade. | `assert(isValidPosition(pos))` a cada tick de movimento. |
| **Ghost Damage** | Unidade morta causa dano final. | No `applyDamage`, checar `if (attacker.isDead) logError()`. |
| **Stuttering** | Unidade vibra tentando decidir alvo/caminho. | Monitorar trocas de alvo/caminho por segundo (> 5/s = erro). |
| **Infinite Range** | Unidade trava no alvo e atira de muito longe. | No ataque, `assert(dist <= range + buffer)`. |
| **Desync** | Visual mostra uma coisa, Lógica faz outra. | Comparar `VisualX` com `LogicX`. Se delta > threshold, desenhar linha vermelha. |
| **Memory Leak** | Jogo fica lento após várias partidas. | Monitorar contagem de instâncias de `UnitState` e `ProjectileState`. |
| **Double Hit** | Projétil AOE acerta o mesmo alvo 2x. | Verificar `hitList` do projétil. |

---

## 3. Debug Overlay & Ferramentas (In-Game)

Uma camada visual sobre o Flame (`BattleDebugLayer`) ativada por flag `kDebugMode`.

### Visualização (Gizmos)
*   **Círculos de Alcance:** Verde (Aggro), Vermelho (Ataque).
*   **Hitboxes:** Retângulos azuis ao redor das unidades (Colisão).
*   **Path Lines:** Linha branca mostrando o próximo waypoint e destino final.
*   **Target Lines:** Linha tracejada vermelha ligando Atacante -> Alvo.
*   **State Label:** Texto flutuante sobre a cabeça: `ID | STATE | HP`.

### Painel de Controle (DevTools)
Botões na UI de Debug:
*   `[ || ]` **Pause/Resume**: Congela o `BattleEngine`.
*   `[ > ]` **Step Tick**: Avança exatamente 1 tick (50ms). Essencial para entender bugs frame-a-frame.
*   `[ x1 ]` `[ x10 ]`: Acelera simulação.
*   `[ +Elixir ]`: Enche a barra de mana.
*   `[ Kill All ]`: Mata todas as unidades (limpa o campo).
*   `[ Spawn ]`: Abre menu para spawnar qualquer unidade em qualquer lugar (ignora regras).

### Painel de Logs (Console In-Game)
Janela rolável transparente mostrando:
```text
[T:145] Unit(12) spawned at (200, 1500)
[T:148] Unit(12) target found: Tower(2)
[T:160] Unit(12) hit Tower(2) for 45 dmg
[T:165] Tower(2) destroyed!
```

---

## 4. Estratégia de Reprodução (Replay System)

Para corrigir bugs complexos que só acontecem "as vezes":

1.  **Gravação Automática:** Toda partida (mesmo dev) grava `seed` e `inputs` num buffer circular ou arquivo temporário.
2.  **Crash Report:** Se o jogo crashar ou um `Assert` falhar, salvar o JSON do replay automaticamente.
3.  **Reprodução:**
    *   Carregar o JSON.
    *   Inicializar `BattleEngine` com a `seed`.
    *   Rodar os inputs nos ticks exatos.
    *   O estado final **DEVE** ser idêntico ao do crash.
4.  **Correção:**
    *   Com o replay rodando, usar o "Step Tick" para chegar no momento exato do erro.
    *   Inspecionar variáveis.
    *   Corrigir código.
    *   Rodar replay novamente para validar correção.

---

## 5. Métricas de Performance

Monitorar em tempo real:
*   **MS per Tick:** Tempo que a CPU leva para calcular 1 tick. (Meta: < 5ms). Se passar de 50ms, o jogo "laga" (slow motion).
*   **Active Entities:** Número de unidades + projéteis.
*   **Draw Calls:** (Flame metrics).

### Ferramenta Sugerida: `BattleProfiler`
Classe que envolve o `update()` do engine e mede `Stopwatch`.
```dart
void update(dt) {
  _stopwatch.start();
  super.update(dt);
  _stopwatch.stop();
  _history.add(_stopwatch.elapsedMicroseconds);
  if (_history.length > 60) _history.removeAt(0);
}
```
