import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  Index,
  Unique,
} from 'typeorm';

@Entity('example_sentences')
@Unique('uq_example_target_cn', ['targetWord', 'cn'])
export class ExampleSentence {
  @PrimaryGeneratedColumn()
  id: number;

  @Index()
  @Column({ name: 'target_word' })
  targetWord: string;

  @Index()
  @Column({ name: 'hsk_level', type: 'int', default: 1 })
  hskLevel: number;

  @Column({ type: 'text' })
  cn: string;

  @Column({ type: 'text', nullable: true })
  py: string;

  @Column({ type: 'text', name: 'vi', nullable: true })
  vi: string;

  @Column({ type: 'text', default: 'Unknown' })
  source: string;

  @Column({ type: 'text', default: 'community' })
  quality: string;

  @Column({ type: 'jsonb', nullable: true })
  tags: object[];

  @Index()
  @Column({ type: 'int', default: 0 })
  score: number;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}
