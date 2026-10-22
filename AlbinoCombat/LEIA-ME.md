# AlbinoCombat — Fase 7

Abra `AlbinoCombat.yyp` no GameMaker e execute com F5 no IDE. Extraia esta pasta separadamente da Fase 6.

## Novidades

- Dois saqueadores e um guardião perseguem o jogador, contornando obstáculos. Os três bonecos de treino anteriores continuam na arena.
- No máximo dois inimigos mantêm um ataque ou sua recuperação ao mesmo tempo. Os demais aguardam; golpes interrompidos liberam a vez.
- Círculo branco: bloqueável/aparável; amarelo: quebra a defesa se não aparado; vermelho: exige esquiva. O guardião alterna os três tipos.
- Gelo reduz movimento e velocidade do ataque; congelamento, atordoamento, hitstop e menu pausam a IA conforme seu estado.
- Execução à distância: com um inimigo atordoado elegível até 520 pixels, pressione MMB (botão central) ou RS (clique do analógico direito). O jogador corre a 8 pixels por quadro, contorna paredes e executa ao chegar a 56 pixels. Prioriza o alvo travado; caso contrário, escolhe o elegível mais próximo.
- A corrida não concede invulnerabilidade. Esquivar cancela; dano que interrompe o personagem, morte do alvo, fim do atordoamento, rota impossível ou limite de 150 quadros também cancelam. A chegada não teleporta ninguém nem prolonga o atordoamento.
- Execução de inimigo comum elimina; elite recebe a regra anterior de dano parcial. A invulnerabilidade permanece somente na animação de execução.
- F11 alterna a IA dos três inimigos ativos para facilitar treino. F5, dentro do jogo, reinicia toda a arena.

## Teste no GameMaker

1. Bloqueie um golpe branco e apare um amarelo; esquive do vermelho do guardião.
2. Encha o atordoamento, afaste-se e use MMB/RS. Confira corrida, chegada e execução.
3. Atordoe um alvo do outro lado da parede; confira que o personagem contorna o obstáculo.
4. Durante a corrida, pressione esquiva. Repita deixando o atordoamento acabar ou sendo atingido.
5. Abra o menu e confira a pausa; use F11 para voltar ao treino parado.

Esta fase usa desenhos procedurais. Não contém os sprites finais nem reproduz os valores internos do jogo de referência. Projeto completo e todo o GML estão incluídos; `CODIGOS_COMPLETOS.md` reúne os códigos para consulta. Não há executável Windows compilado: o runtime do GameMaker não está disponível neste ambiente.

---

## Documentação anterior (controles e sistemas preservados)

# Albino Combat — Fase 6: Socos, Stun, Execucoes e Colera

Extraia em pasta nova; abra AlbinoCombat/AlbinoCombat.yyp. Inclui todas as fases anteriores.

## Controles
4 / D-pad cima: socos. LMB/RB combo de cinco (jab, direto, gancho, soco forte e finalizador); RMB/RT pesado. Alcance curto, menos dano, stun elevado. Socos tambem substituem machado enquanto arremessado.
MMB / clique RS: executa inimigo stunned proximo; se nao houver alvo pronto, continua lock-on. Nenhuma execucao atravessa parede. Alcance 70 px.
Shift+MMB / LS+RS: alterna Colera. Precisa de pelo menos 20 de energia. Todos os socos de Colera liberados; inicia com 100 para testar, consome 12 por segundo, cura 1 HP por golpe e impactos recebidos consomem energia em vez de HP. Desligar/zerar restaura arma anterior. Durante Colera nao pode trocar armas ou usar escudo; recall manual permanece disponivel. Energia e recuperada por ataques normais e execucoes.

## Stun e execucoes
Stun cheio torna inimigo vulneravel por 180 frames de combate. Sem novos golpes, barra parcial decai depois de 120 frames. Hitstop/menu pausam estes tempos. Execucao bloqueia movimento, ataques, troca, esquiva e dano no Player; tambem bloqueia movimento/status/dano externo no alvo. Sequencia de 36 frames, impacto no frame 18. Bonecos comuns morrem; elite recebe 35% do HP maximo (vulnerabilidade por gelo pode aumentar dano). Stun e consumido. Se alvo deixar de existir, Player sai da sequencia com seguranca.

Boneco da direita/baixo e ELITE (800 HP) para teste; outros sao comuns. Continuam parados, sem IA. A animacao e procedural e provisoria. Simulacao de launcher/elevacao fisica nao adicionada nesta fase.

## Checklist
1. Socos: golpes rapidos de curto alcance, pouco dano e stun maior que armas; um acerto por golpe.
2. Encha stun, aproxime-se: indicador MMB/RS aparece. Execute comum: ele morre uma vez, Player retorna livre apos sequencia.
3. Execute elite: dano grande, sem morte instantanea se tiver HP suficiente; barra de stun zera.
4. Espere stunned expirar sem executar; alvo deve voltar a idle e barra zerar.
5. F6/F8 de teste durante execucao: Player nao recebe dano. Tentativa de trocar/esquivar/menu nao interrompe sequencia.
6. MMB distante de stunned continua lock-on; na proximidade vira execucao. Pilar bloqueia alvo.
7. Colera: ativa, socos causam mais dano/stun; recebe golpe F6: energia cai, HP preservado. Termina ao zerar e restaura arma.
8. Vida abaixo do maximo: socos durante Colera curam; fora dela, golpes recuperam energia.
9. Machado arremessado -> socos -> stun -> execucao -> recall; laminas e lanca continuam funcionando.
10. F1/F5 reset, teclado e controle, menu pausando stun/energia. Observe erros completos antes de avancar.

## Arquitetura e arquivos
Novo scr_execution (stun, selecao/execucao, Colera e desenho de socos).
Alterados input, combat, attack data, damage, shield (dano recebido), weapon manager, player, enemy parent, enums e HUD. Nenhum objeto novo. Dados iniciais de cada variavel no Create. Draw sem gameplay. CODIGOS_COMPLETOS.md inclui todos os scripts/events; Step_1=Begin Step, Step_2=End Step, Draw_64=Draw GUI. Mesma room/camadas e heranca de fases anteriores.

## Limites
Compilador GameMaker nao disponivel aqui. Teste integrado necessario no seu IDE. IA e proxima fase; animacoes finais, repertorio avancado e runicos seguem depois.
